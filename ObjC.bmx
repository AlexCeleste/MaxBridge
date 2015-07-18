' BlitzMax-ObjectiveC bridge


SuperStrict


Type ObjCClass Extends ObjCObject Abstract
	Function ForName:ObjCClass(name:String)
		Local _class:Byte Ptr = objc_getClass(name)
		Return bp2class(_class)
	End Function
	Function NewClass:ObjCClass(name:String, _super:ObjCClass, fields:String[])
		Local c:Byte Ptr = objc_allocateClassPair(_ObjCClass(_super)._class, name, 0)
		For Local fld:String = EachIn fields
			class_addIvar(c, fld, SizeOf c, Log(SizeOf c) / Log(2), "@")
		Next
		objc_registerClassPair(c)
		Return bp2class(c)
	End Function
	
	Method Name:String() Abstract
	Method NewObject:ObjCObject() Abstract
	Method ConformsTo:Int(prot:ObjCProtocol) Abstract
	Method SetMethod:Byte Ptr(name:String, impl:Byte Ptr, types:String) Abstract
	Method GetMethod:Byte Ptr(name:String) Abstract
End Type

Type ObjCObject
	Function FromID:ObjCObject(_self:Byte Ptr)
		Return bp2obj(_self)
	End Function
	Function nil:ObjCObject()
		If _nil = Null Then _nil = New Self
		Return _nil
	End Function
	
	Method RespondsToSelector:Int(sel:String)
		Global resp:Byte Ptr ; If Not resp Then resp = sel_registerName("respondsToSelector:")
		Local s:Byte Ptr = sel_registerName(sel)
		Return Int(objc_msgSend1(_self, resp, s))
	End Method
	Method msg:ObjCObject(sel:String, a:ObjCObject[] = Null)
		Local s:Byte Ptr = sel_registerName(sel)
		Select a.Length
			Case 0 ; Return bp2obj(objc_msgSend0(_self, s))
			Case 1 ; Return bp2obj(objc_msgSend1(_self, s, a[0]._self))
			Case 2 ; Return bp2obj(objc_msgSend2(_self, s, a[0]._self, a[1]._self))
			Case 3 ; Return bp2obj(objc_msgSend3(_self, s, a[0]._self, a[1]._self, a[2]._self))
			Case 4 ; Return bp2obj(objc_msgSend4(_self, s, a[0]._self, a[1]._self, a[2]._self, a[3]._self))
			Case 5 ; Return bp2obj(objc_msgSend5(_self, s, a[0]._self, a[1]._self, a[2]._self, a[3]._self, a[4]._self))
			Case 6 ; Return bp2obj(objc_msgSend6(_self, s, a[0]._self, a[1]._self, a[2]._self, a[3]._self, a[4]._self, a[5]._self))
			Case 7 ; Return bp2obj(objc_msgSend7(_self, s, a[0]._self, a[1]._self, a[2]._self, a[3]._self, a[4]._self, a[5]._self, a[6]._self))
			Default ; Return bp2obj(objc_msgSend8(_self, s, a[0]._self, a[1]._self, a[2]._self, a[3]._self, a[4]._self, a[5]._self, a[6]._self, a[7]._self))
		End Select
	End Method
	Method msgRaw:ObjCObject(sel:String, a:Byte Ptr[] = Null)	'for sending raw pointers, e.g. C strings
		Local s:Byte Ptr = sel_registerName(sel)
		Select a.Length
			Case 0 ; Return bp2obj(objc_msgSend0(_self, s))
			Case 1 ; Return bp2obj(objc_msgSend1(_self, s, a[0]))
			Case 2 ; Return bp2obj(objc_msgSend2(_self, s, a[0], a[1]))
			Case 3 ; Return bp2obj(objc_msgSend3(_self, s, a[0], a[1], a[2]))
			Case 4 ; Return bp2obj(objc_msgSend4(_self, s, a[0], a[1], a[2], a[3]))
			Case 5 ; Return bp2obj(objc_msgSend5(_self, s, a[0], a[1], a[2], a[3], a[4]))
			Case 6 ; Return bp2obj(objc_msgSend6(_self, s, a[0], a[1], a[2], a[3], a[4], a[5]))
			Case 7 ; Return bp2obj(objc_msgSend7(_self, s, a[0], a[1], a[2], a[3], a[4], a[5], a[6]))
			Default ; Return bp2obj(objc_msgSend8(_self, s, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
		End Select
	End Method
	Method msgRaw2:Byte Ptr(sel:String, a:Byte Ptr[] = Null)	'for sending and receiving raw pointers
		Local s:Byte Ptr = sel_registerName(sel)
		Select a.Length
			Case 0 ; Return objc_msgSend0(_self, s)
			Case 1 ; Return objc_msgSend1(_self, s, a[0])
			Case 2 ; Return objc_msgSend2(_self, s, a[0], a[1])
			Case 3 ; Return objc_msgSend3(_self, s, a[0], a[1], a[2])
			Case 4 ; Return objc_msgSend4(_self, s, a[0], a[1], a[2], a[3])
			Case 5 ; Return objc_msgSend5(_self, s, a[0], a[1], a[2], a[3], a[4])
			Case 6 ; Return objc_msgSend6(_self, s, a[0], a[1], a[2], a[3], a[4], a[5])
			Case 7 ; Return objc_msgSend7(_self, s, a[0], a[1], a[2], a[3], a[4], a[5], a[6])
			Default ; Return objc_msgSend8(_self, s, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
		End Select
	End Method
	Method GetClass:ObjCClass()
		Return bp2class(object_getClass(_self))
	End Method
	Method SetClass(class:ObjCClass)
		Local c:_ObjCClass = _ObjCClass(class)
		object_setClass(_self, c._class)
	End Method
	Method SetField(f:String, val:ObjCObject)
		object_setInstanceVariable(_self, f, val._self)
	End Method
	Method GetField:ObjCObject(f:String)
		Local _ret:Byte Ptr
		object_getInstanceVariable(_self, f, Varptr _ret)
		Return bp2obj(_ret)
	End Method
	
	Method _Retain:ObjCObject()
		CFRetain(_self) ; Return Self
	End Method
	Method _Release()
		CFRelease(_self)
	End Method
	Method Autorelease:ObjCObject()
		CFAutorelease(_self) ; Return Self
	End Method
	
	Field _self:Byte Ptr
	Global _nil:ObjCObject
	Method Compare:Int(with:Object)
		Local w:ObjCObject = ObjCObject(with) ; If w = Null Then Return Super.Compare(with)
		Local l:Long = Long(_self), lw:Long = Long(w._self)
		If l < lw Then Return -1 ElseIf l = lw Then Return 0 Else Return 1
	End Method
	Method ToString:String()
		Local desc:String = String.FromCString(msg("description").msgRaw2("UTF8String"))
		Return "<ObjCObject: " + desc + ">"
	End Method
	Method Delete()
		If ObjCClass(Self) = Null And Self <> _nil And _self Then CFRelease(_self)
	End Method
End Type

Type ObjCProtocol Abstract
	Function ForName:ObjCProtocol(name:String)
		Local prot:_ObjCProtocol = New _ObjCProtocol
		prot._protocol = objc_getProtocol(name)
		Return prot
	End Function
	Method Name:String() Abstract
End Type

Private

Function bp2obj:ObjCObject(bp:Byte Ptr)
	Local obj:ObjCObject = New ObjCObject
	obj._self = bp
	If bp Then CFRetain(bp)
	Return obj
End Function
Function bp2class:_ObjCClass(bp:Byte Ptr)
	Local c:_ObjCClass = New _ObjCClass
	c._class = bp ; c._self = bp
	Return c
End Function

Type _ObjCClass Extends ObjCClass Final
	Field _class:Byte Ptr, allocSel:Byte Ptr, initSel:Byte Ptr
	
	Method NewObject:ObjCObject()
		If Not allocSel
			allocSel = sel_registerName("alloc") ; initSel = sel_registerName("init")
		EndIf
		Local _obj:Byte Ptr = objc_msgSend0(_class, allocSel), obj:ObjCObject = bp2obj(_obj)
		objc_msgSend0(_obj, initSel)
		Return obj
	End Method
	Method ConformsTo:Int(prot:ObjCProtocol)
		Return class_conformsToProtocol(_class, _ObjCProtocol(prot)._protocol)
	End Method
	Method SetMethod:Byte Ptr(name:String, impl:Byte Ptr, types:String)
		Local sel:Byte Ptr = sel_registerName(name)
		Return class_replaceMethod(_class, sel, impl, types)
	End Method
	Method GetMethod:Byte Ptr(name:String)
		Local sel:Byte Ptr = sel_registerName(name)
		Return class_getMethodImplementation(_class, sel)
	End Method
	Method Name:String()
		Return String.FromCString(class_getName(_class))
	End Method
	
	Method Compare:Int(with:Object)
		Local w:_ObjCClass = _ObjCClass(with) ; If w = Null Then Return Super.Compare(with)
		Local l:Long = Long(_class), lw:Long = Long(w._class)
		If l < lw Then Return -1 ElseIf l = lw Then Return 0 Else Return 1
	End Method
	Method ToString:String()
		Return "<ObjCClass " + Name() + ">"
	End Method
End Type

Type _ObjCProtocol Extends ObjCProtocol Final
	Field _protocol:Byte Ptr
	
	Method Name:String()
		Return String.FromCString(protocol_getName(_protocol))
	End Method
	
	Method Compare:Int(with:Object)
		Local w:_ObjCProtocol = _ObjCProtocol(with) ; If w = Null Then Return Super.Compare(with)
		Local l:Long = Long(_protocol), lw:Long = Long(w._protocol)
		If l < lw Then Return -1 ElseIf l = lw Then Return 0 Else Return 1
	End Method
	Method ToString:String()
		Return "<ObjCProtocol " + Name() + ">"
	End Method
End Type

Extern
	Function objc_getClass:Byte Ptr(name$z)
	Function objc_allocateClassPair:Byte Ptr(_super:Byte Ptr, name$z, extra:Int)
	Function class_addIvar:Int(_class:Byte Ptr, name$z, size:Int, alignment:Byte, types$z)
	Function objc_registerClassPair(_class:Byte Ptr)
	
	Function class_getName:Byte Ptr(_class:Byte Ptr)
	Function class_conformsToProtocol:Int(_class:Byte Ptr, _prot:Byte Ptr)
	Function class_replaceMethod:Byte Ptr(_class:Byte Ptr, name_sel:Byte Ptr, imp:Byte Ptr, types$z)
	Function class_getMethodImplementation:Byte Ptr(_class:Byte Ptr, name_sel:Byte Ptr)
	
	Function object_getClass:Byte Ptr(o:Byte Ptr)
	Function object_setClass:Byte Ptr(o:Byte Ptr, c:Byte Ptr)
	Function object_setInstanceVariable:Byte Ptr(o:Byte Ptr, f$z, val:Byte Ptr)
	Function object_getInstanceVariable:Byte Ptr(o:Byte Ptr, f$z, ret:Byte Ptr Ptr)
	
	Function objc_msgSend0:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend1:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend2:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend3:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend4:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr, _3:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend5:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr, _3:Byte Ptr, _4:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend6:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr, _3:Byte Ptr, _4:Byte Ptr, _5:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend7:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr, _3:Byte Ptr, _4:Byte Ptr, _5:Byte Ptr, _6:Byte Ptr) = "objc_msgSend"
	Function objc_msgSend8:Byte Ptr(_self:Byte Ptr, sel:Byte Ptr, _0:Byte Ptr, _1:Byte Ptr, _2:Byte Ptr, _3:Byte Ptr, _4:Byte Ptr, _5:Byte Ptr, _6:Byte Ptr, _7:Byte Ptr) = "objc_msgSend"
	
	Function objc_getProtocol:Byte Ptr(name$z)
	Function protocol_getName:Byte Ptr(_prot:Byte Ptr)
	
	Function sel_registerName:Byte Ptr(name$z)
	
	Function CFRetain:Byte Ptr(o:Byte Ptr)
	Function CFRelease(o:Byte Ptr)
	Function CFAutorelease:Byte Ptr(o:Byte Ptr)
End Extern

Public

