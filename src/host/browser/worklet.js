function getString(inst, ptr, len) {
    const slice = derefBuffer(Uint8Array, inst, ptr, len);
    const arr = [];

    for (let i = 0; i < slice.length; i++) {
        const char = String.fromCharCode(slice[i]);
        arr.push(char);
    }

    return arr.join('');
}

function derefBuffer(T, inst, ptr, len) {
    return new T(inst.exports.memory.buffer, ptr, len);
}

function allocBuffer(T, inst, len) {
    const ptr = inst.exports.js_alloc(T.BYTES_PER_ELEMENT * len);

    return {
        ptr: ptr,
        data: derefBuffer(T, inst, ptr, len),
    };
}

function freeBuffer(inst, buffer) {
    inst.exports.js_free(buffer.ptr, buffer.data.byteLength);
}

class ZigSynthProcessor extends AudioWorkletProcessor {

    constructor() {
        super();

        this.port.onmessage = this.onMessage.bind(this);
    }

    initWasm(binary, sample_rate) {
        let instance_closure = undefined;

        WebAssembly.instantiate(binary, {
            debug: {
                js_err: (ptr, len) => {
                    const msg = getString(instance_closure, ptr, len);
                    console.error(msg);
                },
                js_warn: (ptr, len) => {
                    const msg = getString(instance_closure, ptr, len);
                    console.log(msg);
                },
            },
        }).then(inst => {
            instance_closure = inst.instance;
            inst.instance.exports.init_synth(sample_rate);
            this.wasm = inst.instance;
        });
    }

    onMessage(event) {
        switch (event.data.type) {
            case 'wasm-binary': {
                this.initWasm(event.data.data, event.data.sample_rate);
                break;
            }

            case 'midi-message': {
                this.processMIDI(event.data.data);
                break;
            }
        }
    }

    processMIDI(data) {
        const buffer = allocBuffer(Uint8Array, this.wasm, data.byteLength);

        buffer.data.set(data);
        this.wasm.exports.process_midi(buffer.ptr, data.byteLength);

        freeBuffer(this.wasm, buffer);
    }

    process(inputs, outputs, params) {
        if (!this.wasm) {
            return true;
        }

        const channel = outputs[0][0];

        // TODO Ideally we want to allocate this buffer only once.
        //      However, I need to figure how to prevent the Zig allocator
        //      from growing the WebAssembly.Memory. When that happens
        //      the underlying ArrayBuffer gets detached and the workmem is
        //      invalidated. Maybe we need to detect this and reallocate?
        //      Although I think it makes more sense to allocate a single slice
        //      at startup and use std.heap.FixedBufferAllocator.
        //
        //      Sadly, we cannot make use of the Performance API in an
        //      Audio Worklet. So I'm unable to measure the performance impact that way.
        //      So far, though, it seems like the dev tools in chrome handle
        //      WebAssembly profiling as well as JavaScript. The accuracy
        //      should be better than that of the Performance API, too.
        const buffer = allocBuffer(Float32Array, this.wasm, channel.length);

        this.wasm.exports.generate(buffer.ptr, buffer.data.length);
        channel.set(buffer.data);

        freeBuffer(this.wasm, buffer);

        return true;
    }

}

registerProcessor('zig-synth', ZigSynthProcessor);
