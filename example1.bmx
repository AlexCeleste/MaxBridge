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
