function clear(ctx) {
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
}

function numMap(x, min, max, new_min, new_max) {
    return (x - min) * (new_max - new_min) / (max - min) + new_min;
}

function drawFrequencies(ctx, audio_ctx, data) {
    const dbToY = db => numMap(db, -120, 6, ctx.canvas.height, 0);
    const freqToX = freq => {
        if (freq === -1) {
            return 0;
        }

        return Math.log10(freq + 1) / Math.log10(audio_ctx.sampleRate / 2) * ctx.canvas.width
    };

    const db_lines = [0, -20, -40, -60, -80, -100, -120];
    db_lines.forEach(db => {
        const y = dbToY(db);

        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(ctx.canvas.width, y);
        ctx.lineWidth = 1;
        ctx.strokeStyle = 'gray';
        ctx.stroke();

        ctx.beginPath();
        ctx.strokeStyle = 'orange';
        ctx.strokeText(`${db} dB`, 4, y - 4);
    });


    const calcX = x => Math.log10(x) / Math.log10(data.length) * ctx.canvas.width;
    const freq_lines = [1, 10, 100, 1000, 10000];

    freq_lines.forEach(freq => {
        const x = freqToX(freq);

        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = 'black';
        ctx.moveTo(x, 0);
        ctx.lineTo(x, ctx.canvas.height);
        ctx.stroke();

        for (let i = 1; i < 10; i++) {
            const thin_x = freqToX(freq + i * freq);

            ctx.beginPath();
            ctx.moveTo(thin_x, 0);
            ctx.lineTo(thin_x, ctx.canvas.height);
            ctx.lineWidth = 1;
            ctx.strokeStyle = 'gray';
            ctx.stroke();
        }

        ctx.beginPath();
        ctx.strokeStyle = 'orange';
        ctx.strokeText(`${freq} Hz`, x + 4, dbToY(0) - 4);
    });

    ctx.beginPath();

    const minp = 0;
    const maxp = audio_ctx.sampleRate / 2;

    const minv = Math.log(0);
    const maxv = Math.log(audio_ctx.sampleRate / 2);
    const scale = (maxv - minv) / (maxp - minp);

    data.forEach((value, i) => {
        const frequency = i * (audio_ctx.sampleRate / 2) / data.length;
        const x = freqToX(frequency);
        const y = numMap(value, -140, 6, ctx.canvas.height, 0);

        if (i == 0) {
            ctx.moveTo(x, y);
            return;
        }

        ctx.lineTo(x, y);
    });

    ctx.strokeStyle = 'blue';
    ctx.lineWidth = 2;
    ctx.stroke();
}

function drawOscilloscope(ctx, audio_ctx, data) {

    ctx.beginPath();
    ctx.moveTo(0, ctx.canvas.height / 2);
    ctx.lineTo(ctx.canvas.width, ctx.canvas.height / 2);
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 3;
    ctx.stroke();

    ctx.beginPath();
    data.forEach((value, i) => {
        const x = (data.length - i) / data.length * ctx.canvas.width;
        const y = ctx.canvas.height / 2 - value * (ctx.canvas.height / 2);

        if (i == 0) {
            ctx.moveTo(x, y);
            return;
        }

        ctx.lineTo(x, y);
    });

    ctx.strokeStyle = 'blue';
    ctx.lineWidth = 2;
    ctx.stroke();
}

const wasm_binary_promise = fetch(window.wasmSource).then(res => res.arrayBuffer());
const play_button = document.getElementById('play-button');

let running = false;

play_button.addEventListener('click', e => start());

window.addEventListener('keydown', onKeyDown);

function onKeyDown(e) {
    window.removeEventListener('keydown', onKeyDown);

    if (e.code === 'Space') {
        start();
    }
}

function start() {
    if (running) {
        return;
    }

    running = true;

    const wrapper = play_button.parentElement;
    wrapper.parentElement.removeChild(wrapper);

    const canvas_spectrum = document.createElement('canvas');
    const canvas_oscilloscope = document.createElement('canvas');
    const ctx_spectrum = canvas_spectrum.getContext('2d');
    const ctx_oscilloscope = canvas_oscilloscope.getContext('2d');

    canvas_spectrum.height = canvas_oscilloscope.height = window.innerHeight / 2;
    canvas_spectrum.width = canvas_oscilloscope.width = window.innerWidth;

    document.body.appendChild(canvas_spectrum);
    document.body.appendChild(canvas_oscilloscope);

    const audio_ctx = new AudioContext();

    audio_ctx.audioWorklet.addModule(window.workletSource).then(() => {
        const analyser = audio_ctx.createAnalyser();

        analyser.fftSize = 512;
        let frequencies = new Float32Array(analyser.frequencyBinCount);
        let samples = new Float32Array(512);

        analyser.smoothingTimeConstant = 0.5;

        function render(t) {

            clear(ctx_spectrum);
            analyser.getFloatFrequencyData(frequencies);
            drawFrequencies(ctx_spectrum, audio_ctx, frequencies);

            clear(ctx_oscilloscope);
            analyser.getFloatTimeDomainData(samples);
            drawOscilloscope(ctx_oscilloscope, audio_ctx, samples);

            requestAnimationFrame(render);
        }

        requestAnimationFrame(render);

        const synth_node = new AudioWorkletNode(audio_ctx, 'zig-synth', {});
        synth_node.connect(analyser).connect(audio_ctx.destination);

        wasm_binary_promise .then(binary => {
            synth_node.port.postMessage({
                type: 'wasm-binary',
                data: binary,
                sample_rate: audio_ctx.sampleRate,
            });
        }).catch(console.error);

        navigator.requestMIDIAccess().then(access => {
            const inputs = access.inputs.values();

            for (const entry of inputs) {
                entry.addEventListener('midimessage', e => {
                    if (synth_node) {
                        synth_node.port.postMessage({
                            type: 'midi-message',
                            data: e.data,
                        });
                    }
                });
            }
        }).catch(console.error);
    });
}

