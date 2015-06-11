# MaxBridge
BlitzMax &lt;-&gt; Objective-C bridge layer

One of the cool things about Objective-C is that its class system is actually completely dynamic: you can create new classes at runtime, change the class of an object after it is created, and even swap out the definition of a method for a different one in the middle of your program's execution. It's like BRL.Reflection on hyper-steroids.

The reason this is cool? It means you can bridge to Objective-C using only a regular C FFI! So even though BlitzMax was only designed for compatibility with C (and a little bit of C++), it's automatically compatible with Objective-C anyway.


Example:

	Import "ObjC.bmx"
	SuperStrict
	
	Local NSString:ObjCClass = ObjCClass.ForName("NSString"), NSObject:ObjCClass = ObjCClass.ForName("NSObject")
	
	Local u:Byte Ptr = "this is a string".ToCString(), v:Byte Ptr = "'%@', '%@'".ToCString()	'try creating an object and calling some methods
	Local s:ObjCObject = NSString.msgRaw("stringWithUTF8String:", [u])
	Local t:ObjCObject = NSString.msgRaw("stringWithUTF8String:", [v])
	Local w:ObjCObject = NSString.msg("stringWithFormat:", [t, s, s])
	Print w.ToString()
	
	Local Foo:ObjCClass = ObjCClass.NewClass("Foo", NSObject, ["x", "y", "z"])	'define a whole new class
	Foo.SetMethod("threeX", threeXImpl, "@:")
	Function threeXImpl:ObjCObject(_self:Byte Ptr, _sel:Byte Ptr)	'use this as a method
		Local me:ObjCObject = ObjCObject.FromID(_self)
		Print "once: " + me.GetField("x").ToString()
		Print "twice: " + me.GetField("x").ToString()
		Print "thrice: " + me.GetField("x").ToString()
		Return Null
	End Function
	
	Local f:ObjCObject = Foo.NewObject()	'use our new class
	f.SetField("x", s)
	f.msg("threeX")
	
	Print "done."
	End


*NB. this works out of the box on OSX because BlitzMax programs link against the Apple runtime. On Windows and Linux you'll need to import an Objective-C runtime and start it up manually. GNUstep is available for those platforms.*

I haven't tested this thoroughly, so there might be errors. The core is sound though, because it's Objective-C's runtime doing all of the work! You can even swap out methods on classes used by BRL.mod (such as the graphics window) and see immediate results:

	Import "ObjC.bmx"
	SuperStrict
	
	Local bbWin:ObjCClass = ObjCClass.ForName("BBGLWindow")
	Local old:Byte Ptr = bbWin.SetMethod("windowShouldClose:", replacement, "@:@")	'replace a method on a BRL class
	
	Global oldMethod:Int(o:Byte Ptr, s:Byte Ptr, _:Byte Ptr) ; oldMethod = old
	Function replacement:Int(obj:Byte Ptr, selector:Byte Ptr, sender:Byte Ptr)
		Print "you pressed the close button!"
		Return oldMethod(obj, selector, sender)
	End Function
	
	Graphics(800, 600, 0)
	While Not KeyDown(KEY_ESCAPE)
		Delay 10
	Wend
	End


(click the window X with the mouse, and the message will be printed)

This isn't a particularly extensive interface and it has many limitations:

- Objects and classes, being proxy/wrapper objects Max-side, need to be compared with `Compare`; `=` and `<>` aren't guaranteed to work (one object could have multiple wrappers).
- Fields added to runtime-generated classes are only allowed to have type `id`.
- Methods need to have a type signature passed along with the implementation when being set (see here - they're not that bad though).
- Methods accept (and must return) raw `Byte Ptr`s to the Objective-C objects, not "wrapped" pointers to `ObjCObject` instances.
- Methods are invoked with `msg` (if you want to pass `id` arguments and return an `id`), `msgRaw` (if you want to pass `Byte Ptr` arguments, like e.g. C strings, and return an `id`), or `msgRaw2` (same as before but also returns a non-wrapped `Byte Ptr` - used to e.g. retrieve a C string representation).
- Methods can't return floats.
- All objects are assumed to be subtypes of `NSObject`. You can use `Retain`/`Release`/`Autorelease` if you really want, although really there will be little need, especially for the first two, since the Max proxy object obviously already retains the Objective-C part.

I've only done the bare minimum for a workable system here, but it should be enough to set you on the way if you need more features. See here for the main Objective-C runtime API if you want to extend it.

[Discuss here.](http://www.blitzbasic.com/Community/posts.php?topic=104657)
