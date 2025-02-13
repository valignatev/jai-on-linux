/*
These are the typedefs at the start of the gl.xml file. They are translated by hand,
because they are just C code embedded into .xml file. Not structured at all
*/
GLenum     :: u32;
GLboolean  :: u8;
GLbitfield :: u32;
GLvoid     :: void; // Not an actual GL type, though used in headers in the past
GLbyte     :: s8;
GLubyte    :: u8;
GLshort    :: s16;
GLushort   :: u16;
GLint      :: s32;
GLuint     :: u32;
GLclampx   :: s32;
GLsizei    :: s32;
GLfloat    :: float32;
GLclampf   :: float32;
GLdouble   :: float64;
GLclampd   :: float64;
GLeglClientBufferEXT :: *void;
GLeglImageOES :: *void;
GLchar    :: s8;
GLcharARB :: s8;

#if OS == .MACOS {
    GLhandleARB :: *void;
} else {
    GLhandleARB :: u32;
}

GLhalf       :: u16;
GLhalfARB    :: u16;
GLfixed      :: s32;
GLintptr     :: s64;
GLintptrARB  :: s64;
GLsizeiptr   :: s64;
GLsizeiptrARB:: s64;
GLint64      :: s64;
GLint64EXT   :: s64;
GLuint64     :: u64;
GLuint64EXT  :: u64;
__GLsync :: struct {};
GLsync :: *__GLsync;
_cl_context :: struct {};
_cl_event :: struct {};
GLDEBUGPROC :: #type (source: GLenum, type: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: *GLchar,userParam: *void) #c_call;
GLDEBUGPROCARB :: GLDEBUGPROC;
GLDEBUGPROCKHR :: GLDEBUGPROC;

// Vendor extension types
GLDEBUGPROCAMD :: #type (id: GLuint, category: GLenum, severity: GLenum, length: GLsizei, message: *u8, userParam: *void) #c_call;
GLhalfNV :: u16;
GLvdpauSurfaceNV :: GLintptr;
GLVULKANPROCNV :: #type () #c_call;
