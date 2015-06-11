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
