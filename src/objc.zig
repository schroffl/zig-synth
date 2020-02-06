pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_longlong;
pub const __uint64_t = c_ulonglong;
pub const __darwin_intptr_t = c_long;
pub const __darwin_natural_t = c_uint;
pub const __darwin_ct_rune_t = c_int;
const union_unnamed_1 = extern union {
    __mbstate8: [128]u8,
    _mbstateL: c_longlong,
};
pub const __mbstate_t = union_unnamed_1;
pub const __darwin_mbstate_t = __mbstate_t;
pub const __darwin_ptrdiff_t = c_long;
pub const __darwin_size_t = c_ulong;
pub const __darwin_va_list = __builtin_va_list;
pub const __darwin_wchar_t = c_int;
pub const __darwin_rune_t = __darwin_wchar_t;
pub const __darwin_wint_t = c_int;
pub const __darwin_clock_t = c_ulong;
pub const __darwin_socklen_t = __uint32_t;
pub const __darwin_ssize_t = c_long;
pub const __darwin_time_t = c_long;
pub const u_int8_t = u8;
pub const u_int16_t = c_ushort;
pub const u_int32_t = c_uint;
pub const u_int64_t = c_ulonglong;
pub const register_t = i64;
pub const user_addr_t = u_int64_t;
pub const user_size_t = u_int64_t;
pub const user_ssize_t = i64;
pub const user_long_t = i64;
pub const user_ulong_t = u_int64_t;
pub const user_time_t = i64;
pub const user_off_t = i64;
pub const syscall_arg_t = u_int64_t;
pub const __darwin_blkcnt_t = __int64_t;
pub const __darwin_blksize_t = __int32_t;
pub const __darwin_dev_t = __int32_t;
pub const __darwin_fsblkcnt_t = c_uint;
pub const __darwin_fsfilcnt_t = c_uint;
pub const __darwin_gid_t = __uint32_t;
pub const __darwin_id_t = __uint32_t;
pub const __darwin_ino64_t = __uint64_t;
pub const __darwin_ino_t = __darwin_ino64_t;
pub const __darwin_mach_port_name_t = __darwin_natural_t;
pub const __darwin_mach_port_t = __darwin_mach_port_name_t;
pub const __darwin_mode_t = __uint16_t;
pub const __darwin_off_t = __int64_t;
pub const __darwin_pid_t = __int32_t;
pub const __darwin_sigset_t = __uint32_t;
pub const __darwin_suseconds_t = __int32_t;
pub const __darwin_uid_t = __uint32_t;
pub const __darwin_useconds_t = __uint32_t;
pub const __darwin_uuid_t = [16]u8;
pub const __darwin_uuid_string_t = [37]u8;
pub const struct___darwin_pthread_handler_rec = extern struct {
    __routine: ?fn (?*c_void) callconv(.C) void,
    __arg: ?*c_void,
    __next: [*c]struct___darwin_pthread_handler_rec,
};
pub const struct__opaque_pthread_attr_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_cond_t = extern struct {
    __sig: c_long,
    __opaque: [40]u8,
};
pub const struct__opaque_pthread_condattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_mutex_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_mutexattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_once_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_rwlock_t = extern struct {
    __sig: c_long,
    __opaque: [192]u8,
};
pub const struct__opaque_pthread_rwlockattr_t = extern struct {
    __sig: c_long,
    __opaque: [16]u8,
};
pub const struct__opaque_pthread_t = extern struct {
    __sig: c_long,
    __cleanup_stack: [*c]struct___darwin_pthread_handler_rec,
    __opaque: [8176]u8,
};
pub const __darwin_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const __darwin_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const __darwin_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const __darwin_pthread_key_t = c_ulong;
pub const __darwin_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const __darwin_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const __darwin_pthread_once_t = struct__opaque_pthread_once_t;
pub const __darwin_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const __darwin_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const __darwin_pthread_t = [*c]struct__opaque_pthread_t;
pub fn _OSSwapInt16(arg__data: __uint16_t) callconv(.C) __uint16_t {
    var _data = arg__data;
    return @bitCast(__uint16_t, @truncate(c_short, ((@bitCast(c_int, @as(c_uint, _data)) << @intCast(@import("std").math.Log2Int(c_int), 8)) | (@bitCast(c_int, @as(c_uint, _data)) >> @intCast(@import("std").math.Log2Int(c_int), 8)))));
} // objc_pre_processed.h:302:9: warning: TODO implement translation of CastKind BuiltinFnToFnPtr
pub const _OSSwapInt32 = @compileError("unable to translate function"); // objc_pre_processed.h:316:9: warning: TODO implement translation of CastKind BuiltinFnToFnPtr
pub const _OSSwapInt64 = @compileError("unable to translate function");
pub const u_char = u8;
pub const u_short = c_ushort;
pub const u_int = c_uint;
pub const u_long = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_quad_t = u_int64_t;
pub const quad_t = i64;
pub const qaddr_t = [*c]quad_t;
pub const caddr_t = [*c]u8;
pub const daddr_t = i32;
pub const dev_t = __darwin_dev_t;
pub const fixpt_t = u_int32_t;
pub const blkcnt_t = __darwin_blkcnt_t;
pub const blksize_t = __darwin_blksize_t;
pub const gid_t = __darwin_gid_t;
pub const in_addr_t = __uint32_t;
pub const in_port_t = __uint16_t;
pub const ino_t = __darwin_ino_t;
pub const ino64_t = __darwin_ino64_t;
pub const key_t = __int32_t;
pub const mode_t = __darwin_mode_t;
pub const nlink_t = __uint16_t;
pub const id_t = __darwin_id_t;
pub const pid_t = __darwin_pid_t;
pub const off_t = __darwin_off_t;
pub const segsz_t = i32;
pub const swblk_t = i32;
pub const uid_t = __darwin_uid_t;
pub const clock_t = __darwin_clock_t;
pub const time_t = __darwin_time_t;
pub const useconds_t = __darwin_useconds_t;
pub const suseconds_t = __darwin_suseconds_t;
pub const rsize_t = __darwin_size_t;
pub const errno_t = c_int;
pub const struct_fd_set = extern struct {
    fds_bits: [32]__int32_t,
};
pub const fd_set = struct_fd_set;
pub fn __darwin_fd_isset(arg__n: c_int, arg__p: [*c]const struct_fd_set) callconv(.C) c_int {
    var _n = arg__n;
    var _p = arg__p;
    return (_p.*.fds_bits[(@bitCast(c_ulong, @as(c_long, _n)) / (@sizeOf(__int32_t) *% @bitCast(c_ulong, @as(c_long, @as(c_int, 8)))))] & (@bitCast(__int32_t, @truncate(c_uint, ((@bitCast(c_ulong, @as(c_long, @as(c_int, 1)))) << @intCast(@import("std").math.Log2Int(c_ulong), (@bitCast(c_ulong, @as(c_long, _n)) % (@sizeOf(__int32_t) *% @bitCast(c_ulong, @as(c_long, @as(c_int, 8)))))))))));
}
pub const fd_mask = __int32_t;
pub const pthread_attr_t = __darwin_pthread_attr_t;
pub const pthread_cond_t = __darwin_pthread_cond_t;
pub const pthread_condattr_t = __darwin_pthread_condattr_t;
pub const pthread_mutex_t = __darwin_pthread_mutex_t;
pub const pthread_mutexattr_t = __darwin_pthread_mutexattr_t;
pub const pthread_once_t = __darwin_pthread_once_t;
pub const pthread_rwlock_t = __darwin_pthread_rwlock_t;
pub const pthread_rwlockattr_t = __darwin_pthread_rwlockattr_t;
pub const pthread_t = __darwin_pthread_t;
pub const pthread_key_t = __darwin_pthread_key_t;
pub const fsblkcnt_t = __darwin_fsblkcnt_t;
pub const fsfilcnt_t = __darwin_fsfilcnt_t;
pub const struct_objc_ivar = extern struct {
    ivar_name: [*c]u8,
    ivar_type: [*c]u8,
    ivar_offset: c_int,
    space: c_int,
};
pub const struct_objc_ivar_list = extern struct {
    ivar_count: c_int,
    space: c_int,
    ivar_list: [1]struct_objc_ivar,
};
pub const struct_objc_method = extern struct {
    method_name: SEL,
    method_types: [*c]u8,
    method_imp: IMP,
};
pub const struct_objc_method_list = extern struct {
    obsolete: [*c]struct_objc_method_list,
    method_count: c_int,
    space: c_int,
    method_list: [1]struct_objc_method,
};
pub const struct_objc_cache = extern struct {
    mask: c_uint,
    occupied: c_uint,
    buckets: [1]Method,
};
pub const struct_objc_protocol_list = extern struct {
    next: [*c]struct_objc_protocol_list,
    count: c_long,
    list: [1][*c]Protocol,
};
pub const struct_objc_class = extern struct {
    isa: Class,
    super_class: Class,
    name: [*c]const u8,
    version: c_long,
    info: c_long,
    instance_size: c_long,
    ivars: [*c]struct_objc_ivar_list,
    methodLists: [*c][*c]struct_objc_method_list,
    cache: [*c]struct_objc_cache,
    protocols: [*c]struct_objc_protocol_list,
};
pub const Class = [*c]struct_objc_class;
pub const struct_objc_object = extern struct {
    isa: Class,
};
pub const id = [*c]struct_objc_object;
pub const struct_objc_selector = @OpaqueType();
pub const SEL = ?*struct_objc_selector;
pub const IMP = ?fn () callconv(.C) void;
pub const BOOL = i8;
pub extern fn sel_getName(sel: SEL) [*c]const u8;
pub extern fn sel_registerName(str: [*c]const u8) SEL;
pub extern fn object_getClassName(obj: id) [*c]const u8;
pub extern fn object_getIndexedIvars(obj: id) ?*c_void;
pub extern fn sel_isMapped(sel: SEL) BOOL;
pub extern fn sel_getUid(str: [*c]const u8) SEL;
pub const objc_objectptr_t = ?*const c_void;
pub extern fn objc_retainedObject(obj: objc_objectptr_t) id;
pub extern fn objc_unretainedObject(obj: objc_objectptr_t) id;
pub extern fn objc_unretainedPointer(obj: id) objc_objectptr_t;
pub const arith_t = c_long;
pub const uarith_t = c_ulong;
pub const STR = [*c]u8;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
pub const int_least8_t = i8;
pub const int_least16_t = i16;
pub const int_least32_t = i32;
pub const int_least64_t = i64;
pub const uint_least8_t = u8;
pub const uint_least16_t = u16;
pub const uint_least32_t = u32;
pub const uint_least64_t = u64;
pub const int_fast8_t = i8;
pub const int_fast16_t = i16;
pub const int_fast32_t = i32;
pub const int_fast64_t = i64;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = u16;
pub const uint_fast32_t = u32;
pub const uint_fast64_t = u64;
pub const intmax_t = c_long;
pub const uintmax_t = c_ulong;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = c_longdouble;
pub const Method = [*c]struct_objc_method;
pub const Ivar = [*c]struct_objc_ivar;
pub const struct_objc_category = extern struct {
    category_name: [*c]u8,
    class_name: [*c]u8,
    instance_methods: [*c]struct_objc_method_list,
    class_methods: [*c]struct_objc_method_list,
    protocols: [*c]struct_objc_protocol_list,
};
pub const Category = [*c]struct_objc_category;
pub const struct_objc_property = @OpaqueType();
pub const objc_property_t = ?*struct_objc_property;
pub const Protocol = struct_objc_object;
pub const struct_objc_method_description = extern struct {
    name: SEL,
    types: [*c]u8,
};
const struct_unnamed_2 = extern struct {
    name: [*c]const u8,
    value: [*c]const u8,
};
pub const objc_property_attribute_t = struct_unnamed_2;
pub extern fn object_copy(obj: id, size: usize) id;
pub extern fn object_dispose(obj: id) id;
pub extern fn object_getClass(obj: id) Class;
pub extern fn object_setClass(obj: id, cls: Class) Class;
pub extern fn object_isClass(obj: id) BOOL;
pub extern fn object_getIvar(obj: id, ivar: Ivar) id;
pub extern fn object_setIvar(obj: id, ivar: Ivar, value: id) void;
pub extern fn object_setIvarWithStrongDefault(obj: id, ivar: Ivar, value: id) void;
pub extern fn object_setInstanceVariable(obj: id, name: [*c]const u8, value: ?*c_void) Ivar;
pub extern fn object_setInstanceVariableWithStrongDefault(obj: id, name: [*c]const u8, value: ?*c_void) Ivar;
pub extern fn object_getInstanceVariable(obj: id, name: [*c]const u8, outValue: [*c]?*c_void) Ivar;
pub extern fn objc_getClass(name: [*c]const u8) Class;
pub extern fn objc_getMetaClass(name: [*c]const u8) Class;
pub extern fn objc_lookUpClass(name: [*c]const u8) Class;
pub extern fn objc_getRequiredClass(name: [*c]const u8) Class;
pub extern fn objc_getClassList(buffer: [*c]Class, bufferCount: c_int) c_int;
pub extern fn objc_copyClassList(outCount: [*c]c_uint) [*c]Class;
pub extern fn class_getName(cls: Class) [*c]const u8;
pub extern fn class_isMetaClass(cls: Class) BOOL;
pub extern fn class_getSuperclass(cls: Class) Class;
pub extern fn class_setSuperclass(cls: Class, newSuper: Class) Class;
pub extern fn class_getVersion(cls: Class) c_int;
pub extern fn class_setVersion(cls: Class, version: c_int) void;
pub extern fn class_getInstanceSize(cls: Class) usize;
pub extern fn class_getInstanceVariable(cls: Class, name: [*c]const u8) Ivar;
pub extern fn class_getClassVariable(cls: Class, name: [*c]const u8) Ivar;
pub extern fn class_copyIvarList(cls: Class, outCount: [*c]c_uint) [*c]Ivar;
pub extern fn class_getInstanceMethod(cls: Class, name: SEL) Method;
pub extern fn class_getClassMethod(cls: Class, name: SEL) Method;
pub extern fn class_getMethodImplementation(cls: Class, name: SEL) IMP;
pub extern fn class_getMethodImplementation_stret(cls: Class, name: SEL) IMP;
pub extern fn class_respondsToSelector(cls: Class, sel: SEL) BOOL;
pub extern fn class_copyMethodList(cls: Class, outCount: [*c]c_uint) [*c]Method;
pub extern fn class_conformsToProtocol(cls: Class, protocol: [*c]Protocol) BOOL;
pub extern fn class_copyProtocolList(cls: Class, outCount: [*c]c_uint) [*c][*c]Protocol;
pub extern fn class_getProperty(cls: Class, name: [*c]const u8) objc_property_t;
pub extern fn class_copyPropertyList(cls: Class, outCount: [*c]c_uint) [*c]objc_property_t;
pub extern fn class_getIvarLayout(cls: Class) [*c]const u8;
pub extern fn class_getWeakIvarLayout(cls: Class) [*c]const u8;
pub extern fn class_addMethod(cls: Class, name: SEL, imp: IMP, types: [*c]const u8) BOOL;
pub extern fn class_replaceMethod(cls: Class, name: SEL, imp: IMP, types: [*c]const u8) IMP;
pub extern fn class_addIvar(cls: Class, name: [*c]const u8, size: usize, alignment: u8, types: [*c]const u8) BOOL;
pub extern fn class_addProtocol(cls: Class, protocol: [*c]Protocol) BOOL;
pub extern fn class_addProperty(cls: Class, name: [*c]const u8, attributes: [*c]const objc_property_attribute_t, attributeCount: c_uint) BOOL;
pub extern fn class_replaceProperty(cls: Class, name: [*c]const u8, attributes: [*c]const objc_property_attribute_t, attributeCount: c_uint) void;
pub extern fn class_setIvarLayout(cls: Class, layout: [*c]const u8) void;
pub extern fn class_setWeakIvarLayout(cls: Class, layout: [*c]const u8) void;
pub extern fn objc_getFutureClass(name: [*c]const u8) Class;
pub extern fn class_createInstance(cls: Class, extraBytes: usize) id;
pub extern fn objc_constructInstance(cls: Class, bytes: ?*c_void) id;
pub extern fn objc_destructInstance(obj: id) ?*c_void;
pub extern fn objc_allocateClassPair(superclass: Class, name: [*c]const u8, extraBytes: usize) Class;
pub extern fn objc_registerClassPair(cls: Class) void;
pub extern fn objc_duplicateClass(original: Class, name: [*c]const u8, extraBytes: usize) Class;
pub extern fn objc_disposeClassPair(cls: Class) void;
pub extern fn method_getName(m: Method) SEL;
pub extern fn method_getImplementation(m: Method) IMP;
pub extern fn method_getTypeEncoding(m: Method) [*c]const u8;
pub extern fn method_getNumberOfArguments(m: Method) c_uint;
pub extern fn method_copyReturnType(m: Method) [*c]u8;
pub extern fn method_copyArgumentType(m: Method, index: c_uint) [*c]u8;
pub extern fn method_getReturnType(m: Method, dst: [*c]u8, dst_len: usize) void;
pub extern fn method_getArgumentType(m: Method, index: c_uint, dst: [*c]u8, dst_len: usize) void;
pub extern fn method_getDescription(m: Method) [*c]struct_objc_method_description;
pub extern fn method_setImplementation(m: Method, imp: IMP) IMP;
pub extern fn method_exchangeImplementations(m1: Method, m2: Method) void;
pub extern fn ivar_getName(v: Ivar) [*c]const u8;
pub extern fn ivar_getTypeEncoding(v: Ivar) [*c]const u8;
pub extern fn ivar_getOffset(v: Ivar) ptrdiff_t;
pub extern fn property_getName(property: objc_property_t) [*c]const u8;
pub extern fn property_getAttributes(property: objc_property_t) [*c]const u8;
pub extern fn property_copyAttributeList(property: objc_property_t, outCount: [*c]c_uint) [*c]objc_property_attribute_t;
pub extern fn property_copyAttributeValue(property: objc_property_t, attributeName: [*c]const u8) [*c]u8;
pub extern fn objc_getProtocol(name: [*c]const u8) [*c]Protocol;
pub extern fn objc_copyProtocolList(outCount: [*c]c_uint) [*c][*c]Protocol;
pub extern fn protocol_conformsToProtocol(proto: [*c]Protocol, other: [*c]Protocol) BOOL;
pub extern fn protocol_isEqual(proto: [*c]Protocol, other: [*c]Protocol) BOOL;
pub extern fn protocol_getName(proto: [*c]Protocol) [*c]const u8;
pub extern fn protocol_getMethodDescription(proto: [*c]Protocol, aSel: SEL, isRequiredMethod: BOOL, isInstanceMethod: BOOL) struct_objc_method_description;
pub extern fn protocol_copyMethodDescriptionList(proto: [*c]Protocol, isRequiredMethod: BOOL, isInstanceMethod: BOOL, outCount: [*c]c_uint) [*c]struct_objc_method_description;
pub extern fn protocol_getProperty(proto: [*c]Protocol, name: [*c]const u8, isRequiredProperty: BOOL, isInstanceProperty: BOOL) objc_property_t;
pub extern fn protocol_copyPropertyList(proto: [*c]Protocol, outCount: [*c]c_uint) [*c]objc_property_t;
pub extern fn protocol_copyPropertyList2(proto: [*c]Protocol, outCount: [*c]c_uint, isRequiredProperty: BOOL, isInstanceProperty: BOOL) [*c]objc_property_t;
pub extern fn protocol_copyProtocolList(proto: [*c]Protocol, outCount: [*c]c_uint) [*c][*c]Protocol;
pub extern fn objc_allocateProtocol(name: [*c]const u8) [*c]Protocol;
pub extern fn objc_registerProtocol(proto: [*c]Protocol) void;
pub extern fn protocol_addMethodDescription(proto: [*c]Protocol, name: SEL, types: [*c]const u8, isRequiredMethod: BOOL, isInstanceMethod: BOOL) void;
pub extern fn protocol_addProtocol(proto: [*c]Protocol, addition: [*c]Protocol) void;
pub extern fn protocol_addProperty(proto: [*c]Protocol, name: [*c]const u8, attributes: [*c]const objc_property_attribute_t, attributeCount: c_uint, isRequiredProperty: BOOL, isInstanceProperty: BOOL) void;
pub extern fn objc_copyImageNames(outCount: [*c]c_uint) [*c][*c]const u8;
pub extern fn class_getImageName(cls: Class) [*c]const u8;
pub extern fn objc_copyClassNamesForImage(image: [*c]const u8, outCount: [*c]c_uint) [*c][*c]const u8;
pub extern fn sel_isEqual(lhs: SEL, rhs: SEL) BOOL;
pub extern fn objc_enumerationMutation(obj: id) void;
pub extern fn objc_setEnumerationMutationHandler(handler: ?fn (id) callconv(.C) void) void;
pub extern fn objc_setForwardHandler(fwd: ?*c_void, fwd_stret: ?*c_void) void;
pub extern fn imp_implementationWithBlock(block: id) IMP;
pub extern fn imp_getBlock(anImp: IMP) id;
pub extern fn imp_removeBlock(anImp: IMP) BOOL;
pub extern fn objc_loadWeak(location: [*c]id) id;
pub extern fn objc_storeWeak(location: [*c]id, obj: id) id;
pub const objc_AssociationPolicy = usize;
pub const OBJC_ASSOCIATION_ASSIGN = @enumToInt(enum_unnamed_3.OBJC_ASSOCIATION_ASSIGN);
pub const OBJC_ASSOCIATION_RETAIN_NONATOMIC = @enumToInt(enum_unnamed_3.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
pub const OBJC_ASSOCIATION_COPY_NONATOMIC = @enumToInt(enum_unnamed_3.OBJC_ASSOCIATION_COPY_NONATOMIC);
pub const OBJC_ASSOCIATION_RETAIN = @enumToInt(enum_unnamed_3.OBJC_ASSOCIATION_RETAIN);
pub const OBJC_ASSOCIATION_COPY = @enumToInt(enum_unnamed_3.OBJC_ASSOCIATION_COPY);
const enum_unnamed_3 = extern enum(c_int) {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 769,
    OBJC_ASSOCIATION_COPY = 771,
    _,
};
pub extern fn objc_setAssociatedObject(object: id, key: ?*const c_void, value: id, policy: objc_AssociationPolicy) void;
pub extern fn objc_getAssociatedObject(object: id, key: ?*const c_void) id;
pub extern fn objc_removeAssociatedObjects(object: id) void;
pub const objc_hook_getImageName = ?fn (Class, [*c][*c]const u8) callconv(.C) BOOL;
pub extern fn objc_setHook_getImageName(newValue: objc_hook_getImageName, outOldValue: [*c]objc_hook_getImageName) void;
pub const objc_hook_getClass = ?fn ([*c]const u8, [*c]Class) callconv(.C) BOOL;
pub extern fn objc_setHook_getClass(newValue: objc_hook_getClass, outOldValue: [*c]objc_hook_getClass) void;
pub const objc_hook_setAssociatedObject = ?fn (id, ?*const c_void, id, objc_AssociationPolicy) callconv(.C) void;
pub extern fn objc_setHook_setAssociatedObject(newValue: objc_hook_setAssociatedObject, outOldValue: [*c]objc_hook_setAssociatedObject) void;
pub const struct_mach_header = @OpaqueType();
pub const objc_func_loadImage = ?fn (?*const struct_mach_header) callconv(.C) void;
pub extern fn objc_addLoadImageFunc(func: objc_func_loadImage) void;
pub const _objc_swiftMetadataInitializer = ?fn (Class, ?*c_void) callconv(.C) Class;
pub extern fn _objc_realizeClassFromSwift(cls: Class, previously: ?*c_void) Class;
pub const struct_objc_method_description_list = extern struct {
    count: c_int,
    list: [1]struct_objc_method_description,
};
pub const struct_objc_symtab = extern struct {
    sel_ref_cnt: c_ulong,
    refs: [*c]SEL,
    cls_def_cnt: c_ushort,
    cat_def_cnt: c_ushort,
    defs: [1]?*c_void,
};
pub const Symtab = [*c]struct_objc_symtab;
pub const Cache = [*c]struct_objc_cache;
pub const struct_objc_module = extern struct {
    version: c_ulong,
    size: c_ulong,
    name: [*c]const u8,
    symtab: Symtab,
};
pub const Module = [*c]struct_objc_module;
pub extern fn class_lookupMethod(cls: Class, sel: SEL) IMP;
pub extern fn class_respondsToMethod(cls: Class, sel: SEL) BOOL;
pub extern fn _objc_flush_caches(cls: Class) void;
pub extern fn object_copyFromZone(anObject: id, nBytes: usize, z: ?*c_void) id;
pub extern fn object_realloc(anObject: id, nBytes: usize) id;
pub extern fn object_reallocFromZone(anObject: id, nBytes: usize, z: ?*c_void) id;
pub extern fn objc_getClasses() ?*c_void;
pub extern fn objc_addClass(myClass: Class) void;
pub extern fn objc_setClassHandler(?fn ([*c]const u8) callconv(.C) c_int) void;
pub extern fn objc_setMultithreaded(flag: BOOL) void;
pub extern fn class_createInstanceFromZone(Class, idxIvars: usize, z: ?*c_void) id;
pub extern fn class_addMethods(Class, [*c]struct_objc_method_list) void;
pub extern fn class_removeMethods(Class, [*c]struct_objc_method_list) void;
pub extern fn _objc_resolve_categories_for_class(cls: Class) void;
pub extern fn class_poseAs(imposter: Class, original: Class) Class;
pub extern fn method_getSizeOfArguments(m: Method) c_uint;
pub extern fn method_getArgumentInfo(m: [*c]struct_objc_method, arg: c_int, type: [*c][*c]const u8, offset: [*c]c_int) c_uint;
pub extern fn objc_getOrigClass(name: [*c]const u8) Class;
pub extern fn class_nextMethodList(Class, [*c]?*c_void) [*c]struct_objc_method_list;
pub extern var _alloc: ?fn (Class, usize) callconv(.C) id;
pub extern var _copy: ?fn (id, usize) callconv(.C) id;
pub extern var _realloc: ?fn (id, usize) callconv(.C) id;
pub extern var _dealloc: ?fn (id) callconv(.C) id;
pub extern var _zoneAlloc: ?fn (Class, usize, ?*c_void) callconv(.C) id;
pub extern var _zoneRealloc: ?fn (id, usize, ?*c_void) callconv(.C) id;
pub extern var _zoneCopy: ?fn (id, usize, ?*c_void) callconv(.C) id;
pub const struct___va_list_tag = extern struct {
    gp_offset: c_uint,
    fp_offset: c_uint,
    overflow_arg_area: ?*c_void,
    reg_save_area: ?*c_void,
};
pub extern var _error: ?fn (id, [*c]const u8, [*c]struct___va_list_tag) callconv(.C) void;
pub const struct_objc_super = extern struct {
    receiver: id,
    class: Class,
};
pub extern fn objc_msgSend(self: id, op: SEL, ...) id;
pub extern fn objc_msgSendSuper() void;
pub extern fn objc_msgSend_stret() void;
pub extern fn objc_msgSendSuper_stret() void;
pub extern fn objc_msgSend_fpret() void;
pub extern fn objc_msgSend_fp2ret() void;
pub extern fn method_invoke() void;
pub extern fn method_invoke_stret() void;
pub extern fn _objc_msgForward() void;
pub extern fn _objc_msgForward_stret() void;
pub const marg_list = ?*c_void;
pub extern fn objc_msgSendv(self: id, op: SEL, arg_size: usize, arg_frame: marg_list) id;
pub extern fn objc_msgSendv_stret(stretAddr: ?*c_void, self: id, op: SEL, arg_size: usize, arg_frame: marg_list) void;
pub const __INTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __PTRDIFF_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __SIZE_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __CHAR16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __CHAR32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_LEAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_LEAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_FAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_FAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __INT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __UINT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id.Identifier");
pub const __AVX__ = 1;
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __FINITE_MATH_ONLY__ = 0;
pub const __SIZEOF_FLOAT__ = 4;
pub const __SEG_GS = 1;
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_MAX__ = 127;
pub const __tune_corei7__ = 1;
pub const __OBJC_BOOL_IS_BOOL = 0;
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT64_FMTX__ = "llX";
pub const __SSE4_2__ = 1;
pub const __SIG_ATOMIC_MAX__ = 2147483647;
pub const __SSE__ = 1;
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __NO_MATH_INLINES = 1;
pub const __INT_FAST32_FMTd__ = "d";
pub const __STDC_UTF_16__ = 1;
pub const __UINT_FAST16_MAX__ = 65535;
pub const __ATOMIC_ACQUIRE = 2;
pub const __LDBL_HAS_DENORM__ = 1;
pub const __INTMAX_FMTi__ = "li";
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FMA__ = 1;
pub const __APPLE__ = 1;
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT32_MAX__ = @as(c_uint, 4294967295);
pub const __INT_MAX__ = 2147483647;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1;
pub const __SIZEOF_INT128__ = 16;
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __DBL_MIN_10_EXP__ = -307;
pub const __INT_LEAST32_MAX__ = 2147483647;
pub const __INT_FAST16_FMTd__ = "hd";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __UINT8_FMTu__ = "hhu";
pub const __INT_FAST16_MAX__ = 32767;
pub const __INVPCID__ = 1;
pub const __LP64__ = 1;
pub const __SIZE_FMTx__ = "lx";
pub const __ORDER_PDP_ENDIAN__ = 3412;
pub const __UINT8_FMTX__ = "hhX";
pub const __LDBL_MIN_10_EXP__ = -4931;
pub const __LDBL_MAX_10_EXP__ = 4932;
pub const __DBL_MAX_10_EXP__ = 308;
pub const __PTRDIFF_FMTi__ = "li";
pub const __CLFLUSHOPT__ = 1;
pub const __FLT_MIN_EXP__ = -125;
pub const __SIZEOF_LONG__ = 8;
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __FLT_EVAL_METHOD__ = 0;
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __code_model_small_ = 1;
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const _LP64 = 1;
pub const __FLT_MAX_EXP__ = 128;
pub const __DBL_HAS_DENORM__ = 1;
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __SSSE3__ = 1;
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __STDC_NO_THREADS__ = 1;
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __LZCNT__ = 1;
pub const __SSP_STRONG__ = 2;
pub const __clang_patchlevel__ = 1;
pub const __UINT64_FMTu__ = "llu";
pub const __SIZEOF_SHORT__ = 2;
pub const __LDBL_DIG__ = 18;
pub const __MPX__ = 1;
pub const __OPENCL_MEMORY_SCOPE_DEVICE = 2;
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __MMX__ = 1;
pub const __SIZEOF_WINT_T__ = 4;
pub const __NO_INLINE__ = 1;
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1;
pub const __INTMAX_C_SUFFIX__ = L;
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __LITTLE_ENDIAN__ = 1;
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = 0;
pub const __VERSION__ = "Clang 9.0.1 (https://github.com/llvm/llvm-project.git 432bf48c08da748e2542cf40e3ab9aee53a744b0)";
pub const __DBL_HAS_INFINITY__ = 1;
pub const __INT_LEAST16_MAX__ = 32767;
pub const __SCHAR_MAX__ = 127;
pub const __GNUC_MINOR__ = 2;
pub const __UINT32_FMTx__ = "x";
pub const __corei7 = 1;
pub const __LDBL_HAS_QUIET_NAN__ = 1;
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __pic__ = 2;
pub const __RTM__ = 1;
pub const __clang__ = 1;
pub const __FLT_HAS_INFINITY__ = 1;
pub const __UINTPTR_FMTu__ = "lu";
pub const __INT_FAST32_TYPE__ = int;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1;
pub const __UINT16_FMTx__ = "hx";
pub const __ADX__ = 1;
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __FLT_MIN_10_EXP__ = -37;
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __UINT_LEAST32_MAX__ = @as(c_uint, 4294967295);
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZEOF_POINTER__ = 8;
pub const __SIZE_FMTX__ = "lX";
pub const __nullable = _Nullable;
pub const __INT16_FMTd__ = "hd";
pub const __clang_version__ = "9.0.1 (https://github.com/llvm/llvm-project.git 432bf48c08da748e2542cf40e3ab9aee53a744b0)";
pub const __ATOMIC_RELEASE = 3;
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __INTMAX_FMTd__ = "ld";
pub const __SEG_FS = 1;
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __WINT_WIDTH__ = 32;
pub const __FLT_MAX_10_EXP__ = 38;
pub const __LDBL_MAX__ = @as(f64, 1.18973149535723176502e+4932);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = 2;
pub const _DEBUG = 1;
pub const __UINTPTR_WIDTH__ = 64;
pub const __INT_LEAST32_FMTi__ = "i";
pub const __WCHAR_WIDTH__ = 32;
pub const __UINT16_FMTX__ = "hX";
pub const __MACH__ = 1;
pub const __GNUC_PATCHLEVEL__ = 1;
pub const __INT_LEAST16_TYPE__ = short;
pub const __APPLE_CC__ = 6000;
pub const __INT64_FMTd__ = "lld";
pub const __SSE3__ = 1;
pub const __UINT16_MAX__ = 65535;
pub const __ATOMIC_RELAXED = 0;
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __SSE2__ = 1;
pub const __STDC__ = 1;
pub const __block = __attribute__(__blocks__(byref));
pub const __INT_FAST16_TYPE__ = short;
pub const __UINT64_C_SUFFIX__ = ULL;
pub const __LONG_MAX__ = @as(c_long, 9223372036854775807);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __CHAR_BIT__ = 8;
pub const __DBL_DECIMAL_DIG__ = 17;
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __FSGSBASE__ = 1;
pub const __ORDER_BIG_ENDIAN__ = 4321;
pub const __DYNAMIC__ = 1;
pub const __INTPTR_MAX__ = @as(c_long, 9223372036854775807);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INTMAX_WIDTH__ = 64;
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = 2;
pub const __LDBL_DENORM_MIN__ = @as(f64, 3.64519953188247460253e-4951);
pub const __x86_64 = 1;
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = 101500;
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = 2;
pub const __INTMAX_MAX__ = @as(c_long, 9223372036854775807);
pub const __INT8_FMTd__ = "hhd";
pub const __UINTMAX_WIDTH__ = 64;
pub const __UINT8_MAX__ = 255;
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __PRAGMA_REDEFINE_EXTNAME = 1;
pub const __DBL_HAS_QUIET_NAN__ = 1;
pub const __clang_minor__ = 0;
pub const __LDBL_DECIMAL_DIG__ = 21;
pub const __SSE4_1__ = 1;
pub const __WCHAR_TYPE__ = int;
pub const __INT_FAST64_FMTd__ = "lld";
pub const __RDRND__ = 1;
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __seg_fs = __attribute__(address_space(257));
pub const __XSAVEOPT__ = 1;
pub const __UINTMAX_FMTX__ = "lX";
pub const __INT16_FMTi__ = "hi";
pub const __LDBL_MIN_EXP__ = -16381;
pub const __PRFCHW__ = 1;
pub const __AVX2__ = 1;
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT32_FMTu__ = "u";
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1;
pub const __SIG_ATOMIC_WIDTH__ = 32;
pub const __amd64__ = 1;
pub const __null_unspecified = _Null_unspecified;
pub const __INT64_C_SUFFIX__ = LL;
pub const __LDBL_EPSILON__ = @as(f64, 1.08420217248550443401e-19);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = 2;
pub const __SSE2_MATH__ = 1;
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = 2;
pub const __SGX__ = 1;
pub const __POPCNT__ = 1;
pub const __POINTER_WIDTH__ = 64;
pub const __UINT64_FMTx__ = "llx";
pub const __ATOMIC_ACQ_REL = 4;
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __STDC_HOSTED__ = 1;
pub const __GNUC__ = 4;
pub const __INT_FAST32_FMTi__ = "i";
pub const __PIC__ = 2;
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __seg_gs = __attribute__(address_space(256));
pub const __FXSR__ = 1;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __STDC_UTF_32__ = 1;
pub const __PTRDIFF_WIDTH__ = 64;
pub const __SIZE_WIDTH__ = 64;
pub const __LDBL_MIN__ = @as(f64, 3.36210314311209350626e-4932);
pub const __UINTMAX_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __SIZEOF_PTRDIFF_T__ = 8;
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT16_FMTu__ = "hu";
pub const __DBL_MANT_DIG__ = 53;
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __GNUC_STDC_INLINE__ = 1;
pub const __weak = __attribute__(objc_gc(weak));
pub const __UINT32_FMTX__ = "X";
pub const __DBL_DIG__ = 15;
pub const __SHRT_MAX__ = 32767;
pub const __ATOMIC_CONSUME = 1;
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __INT32_FMTd__ = "d";
pub const __INT8_MAX__ = 127;
pub const __FLT_DECIMAL_DIG__ = 9;
pub const __INT_LEAST32_FMTd__ = "d";
pub const __UINT8_FMTo__ = "hho";
pub const __FLT_HAS_DENORM__ = 1;
pub const __FLT_DIG__ = 6;
pub const __USER_LABEL_PREFIX__ = _;
pub const __INTPTR_FMTi__ = "li";
pub const __UINT32_FMTo__ = "o";
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __GXX_ABI_VERSION = 1002;
pub const __SIZEOF_LONG_LONG__ = 8;
pub const __WINT_TYPE__ = int;
pub const __INT32_TYPE__ = int;
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = 3;
pub const __UINTPTR_FMTX__ = "lX";
pub const __INT8_FMTi__ = "hhi";
pub const __SIZEOF_LONG_DOUBLE__ = 16;
pub const __DBL_MIN_EXP__ = -1021;
pub const __INT_FAST64_FMTi__ = "lli";
pub const __INT64_FMTi__ = "lli";
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1;
pub const __clang_major__ = 9;
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = 4;
pub const __INT16_MAX__ = 32767;
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __UINT16_FMTo__ = "ho";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __XSAVES__ = 1;
pub const __UINT_LEAST8_MAX__ = 255;
pub const __LDBL_HAS_INFINITY__ = 1;
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __nonnull = _Nonnull;
pub const __UINT_LEAST16_MAX__ = 65535;
pub const __CONSTANT_CFSTRINGS__ = 1;
pub const __SSE_MATH__ = 1;
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __llvm__ = 1;
pub const __DBL_MAX_EXP__ = 1024;
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __GCC_ASM_FLAG_OUTPUTS__ = 1;
pub const __PTRDIFF_MAX__ = @as(c_long, 9223372036854775807);
pub const __ORDER_LITTLE_ENDIAN__ = 1234;
pub const __INT16_TYPE__ = short;
pub const __PCLMUL__ = 1;
pub const __UINTPTR_FMTx__ = "lx";
pub const __LDBL_MAX_EXP__ = 16384;
pub const __UINT_FAST32_MAX__ = @as(c_uint, 4294967295);
pub const __AES__ = 1;
pub const __FLT_RADIX__ = 2;
pub const __amd64 = 1;
pub const __WINT_MAX__ = 2147483647;
pub const __UINTPTR_FMTo__ = "lo";
pub const __INT32_MAX__ = 2147483647;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_WIDTH__ = 64;
pub const __XSAVE__ = 1;
pub const __INT_FAST32_MAX__ = 2147483647;
pub const __INT32_FMTi__ = "i";
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __RDSEED__ = 1;
pub const __GCC_ATOMIC_INT_LOCK_FREE = 2;
pub const __FLT_HAS_QUIET_NAN__ = 1;
pub const __corei7__ = 1;
pub const __MOVBE__ = 1;
pub const __INT_LEAST32_TYPE__ = int;
pub const __BIGGEST_ALIGNMENT__ = 16;
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __SIZE_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __BLOCKS__ = 1;
pub const __XSAVEC__ = 1;
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __UINTPTR_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __UINT_FAST32_FMTx__ = "x";
pub const __PTRDIFF_FMTd__ = "ld";
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __WCHAR_MAX__ = 2147483647;
pub const __ATOMIC_SEQ_CST = 5;
pub const __LDBL_MANT_DIG__ = 64;
pub const __UINT_FAST8_MAX__ = 255;
pub const __SIZEOF_SIZE_T__ = 8;
pub const __BMI2__ = 1;
pub const __STDC_VERSION__ = @as(c_long, 201112);
pub const __F16C__ = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = 1;
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = 1;
pub const __SIZEOF_INT__ = 4;
pub const OBJC_NEW_PROPERTIES = 1;
pub const __UINT32_C_SUFFIX__ = U;
pub const __x86_64__ = 1;
pub const __BMI__ = 1;
pub const __FLT_MANT_DIG__ = 24;
pub const __INT_LEAST8_MAX__ = 127;
pub const __UINTMAX_FMTo__ = "lo";
pub const __SIZE_FMTo__ = "lo";
pub const __SIZEOF_DOUBLE__ = 8;
pub const __SIZEOF_WCHAR_T__ = 4;
pub const __darwin_pthread_handler_rec = struct___darwin_pthread_handler_rec;
pub const _opaque_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const _opaque_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const _opaque_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const _opaque_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const _opaque_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const _opaque_pthread_once_t = struct__opaque_pthread_once_t;
pub const _opaque_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const _opaque_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const _opaque_pthread_t = struct__opaque_pthread_t;
pub const objc_ivar = struct_objc_ivar;
pub const objc_ivar_list = struct_objc_ivar_list;
pub const objc_method = struct_objc_method;
pub const objc_method_list = struct_objc_method_list;
pub const objc_cache = struct_objc_cache;
pub const objc_protocol_list = struct_objc_protocol_list;
pub const objc_class = struct_objc_class;
pub const objc_object = struct_objc_object;
pub const objc_selector = struct_objc_selector;
pub const objc_category = struct_objc_category;
pub const objc_property = struct_objc_property;
pub const objc_method_description = struct_objc_method_description;
pub const mach_header = struct_mach_header;
pub const objc_method_description_list = struct_objc_method_description_list;
pub const objc_symtab = struct_objc_symtab;
pub const objc_module = struct_objc_module;
pub const __va_list_tag = struct___va_list_tag;
pub const objc_super = struct_objc_super;
