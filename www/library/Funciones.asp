<!--#include virtual="/itdap/helpdesk/connections/HelpDesk.asp" -->

<script runat="server" language="VBScript" type="text/vbscript">


Function GetIDFromKey(IDName, vKey)

Dim vReturnValue, vPosNext, vValue

vPosNext = InStr(1, vKey, IDName) + 1
vValue = Mid(vKey, vPosNext,1)
While IsNumeric(vValue)
	vReturnValue = vReturnValue & vValue
	vPosNext = vPosNext +1
	vValue = Mid(vKey, vPosNext,1)
Wend

If Not IsNumeric(vReturnValue) Then
	vReturnValue = 0
End If

GetIDFromKey = CLng(vReturnValue)

End Function



Function GetWhereFromRequest(vData)

Dim vPosLast, vPosNext, vValue, vField, vPosValue, vWhere, strNullValue

	'Ejecuta los reemplazos en la info del form
	vData = Replace(vData, "%2F", "/")

	strNullValue = "NULL"

    vPosLast = 1
    vPosNext = InStr(vPosLast, vData, "&") + 1

    'Definir vWhere
    While (vPosNext <> 0 And vPosNext < Len(vData))
        vPosValue = InStr(vPosLast, vData, "=") + 1

        If vPosValue = 1 Then
			vValue = ""
			vPosNext = InStr(vPosLast, vData, "&") + 1
        Else
			vField = Mid(vData, vPosLast, vPosValue - vPosLast - 1)

			vPosNext = InStr(vPosLast, vData, "&") + 1

			vValue = Mid(vData, vPosValue, vPosNext - vPosValue - 1)
		End If

        'Evalua los valores recibidos en el Form o QueryString (los que empiezan con % para Like, y _ para igual)
        If Len(vValue) > 0 Then

            Select Case Mid(vField, 1, 2)
            Case "C1"    'Consultas por igual
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

				If vValue = strNullValue Then
					vWhere = vWhere & Mid(vField, 3) & " IS NULL"
				Else
					If IsDate(vValue) Then
						vValue = "'" & Month(vValue) & "/" & Day(vValue) & "/" & Year(vValue) & "'"
					ElseIf Not IsNumeric(vValue) Then
					    vValue = "'" & vValue & "'"
					End If

					vWhere = vWhere & Mid(vField, 3) & "=" & vValue
				End If
            Case "C2"    'Consultas por like
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

                vWhere = vWhere & Mid(vField, 3) & " like'%" & vValue & "%'"
            Case "C3"    'Consultas por Menor o igual
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

				If IsDate(vValue) Then
					vValue = "'" & Month(vValue) & "/" & Day(vValue) & "/" & Year(vValue) & "'"
				ElseIf Not IsNumeric(vValue) Then
				    vValue = "'" & vValue & "'"
				End If

                vWhere = vWhere & Mid(vField, 3) & " <=" & vValue
            Case "C4"    'Consultas por Mayor o igual
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

				If IsDate(vValue) Then
					vValue = "'" & Month(vValue) & "/" & Day(vValue) & "/" & Year(vValue) & "'"
				ElseIf Not IsNumeric(vValue) Then
				    vValue = "'" & vValue & "'"
				End If

                vWhere = vWhere & Mid(vField, 3) & " >=" & vValue
            Case "C5"    'Consultas por distinto
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

				If vValue = strNullValue Then
					vWhere = vWhere & "NOT " & Mid(vField, 3) & " IS NULL"
				Else
					If IsDate(vValue) Then
						vValue = "'" & Month(vValue) & "/" & Day(vValue) & "/" & Year(vValue) & "'"
					ElseIf Not IsNumeric(vValue) Then
					    vValue = "'" & vValue & "'"
					End If

					vWhere = vWhere & "NOT " & Mid(vField, 3) & "=" & vValue
				End If
            Case "C6"    'Consultas por like (inicio)
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

                vWhere = vWhere & Mid(vField, 3) & " like'" & vValue & "%'"
            Case "C7"    'Consultas por like (inicio)
				If Not Len(vWhere) = 0 Then
				    vWhere = vWhere & " AND "
				End If

                vWhere = vWhere & Mid(vField, 3) & " like'%;" & vValue & "%'"
            End Select
        End If


        vPosLast = vPosNext

    Wend

	GetWhereFromRequest = vWhere

End Function



Function ReadField(vRS, FieldName, DefaultValue, vForm)

	Dim vResponse

	On Error Resume Next

	If Len("" & DefaultValue) = 0 Then
		vResponse = ""
	Else
		vResponse = DefaultValue
	End If

	If Not vForm Is Nothing Then
		If Not vForm(FieldName).Count = 0 Then
			vResponse = vForm(FieldName)
		ElseIf Not vRS.EOF Then
			If Not IsNull(vRS(FieldName).Value) Then
				vResponse = vRS(FieldName).Value
			End If
		End If
	ElseIf Not vRS.EOF Then
		If Not IsNull(vRS(FieldName).Value) Then
			vResponse = vRS(FieldName).Value
		End If
	End If

	ReadField = vResponse

End Function




function GetPageName()
	nameofpage = Request.ServerVariables("URL")
	nameofpage=Right(nameofpage, Len(nameofpage)-InStrRev(nameofpage, "/"))
	GetPageName = nameofpage
End Function




Function VerifyFormField(FieldName, DefaultValue, vForm)
'Lee un valor de campo de un form y lo escribe en el Response'
	Dim vResponse
    Dim vExisteCampo
	On Error Resume Next
	If Not vForm(FieldName).Count = 0 Then
	   vExisteCampo = true
	Else
	   vExisteCampo = false
	End if
	vResponse = DefaultValue
	If IsDate(DefaultValue) then
	   	If vExisteCampo then
		   If IsDate(vForm(FieldName)) Then
			  vResponse = vForm(FieldName)
		   End if
		End If
	Else
		If IsNumber(DefaultValue) then
			If vExisteCampo then
				If IsNumber(vForm(FieldName)) Then
				  vResponse = vForm(FieldName)
				End if
			End If
		Else
			If vExisteCampo then
				If Len(vForm(FieldName)) <> 0 Then
				  vResponse = vForm(FieldName)
				end if
			End If
		End If
	End If
	VerifyFormField = vResponse

End Function




Function LoadList(vRS, vSelectedValue)
'Carga una lista con los valores de un recordset.'
'Selecciona el elemento con el valor especificado.'

	Dim vResponse

	if isnull(vSelectedValue) Then
		vSelectedValue = ""
	End If

	If not vRS.BOF Then
		vRS.MoveFirst
	End If
	While Not vRS.EOF
		vResponse = "<option "
		If CStr(vRS(0)) = CStr(vSelectedValue) Then
			vResponse = vResponse & "selected "
		End If
		vResponse = vResponse & "value=" & vRS(0) & ">" & vRS(1) & "</option>"
		Response.Write vResponse
	vRS.MoveNext
	Wend
	If not vRS.BOF Then
		vRS.MoveFirst
	End If

End Function




Function ReadLang(vRS,IDLenguaje)
While Not vRS.EOF


		If CStr(vRS(0)) = CStr(IDLenguaje) Then
			Response.Write vRS(2)
			ReadLang = vRS(2)
		End If

	vRS.MoveNext
	Wend
	vRS.MoveFirst

End Function




Function GetURL
	If Request.ServerVariables("QUERY_STRING") = "" Then
		GetURL = Request.ServerVariables("URL")
	Else
		GetURL = Request.ServerVariables("URL") & "?" & Request.ServerVariables("QUERY_STRING")
	End If
End Function




Function GetURLBase()
	GetURLBase = Request.ServerVariables("SERVER_NAME") & Mid(Request.ServerVariables("URL"),1,InStrRev(Request.ServerVariables("URL"),"/"))
End Function

Function GetURLPreview()

	If Request.Form = "" Then
		If Request.ServerVariables("QUERY_STRING") = "" Then
			GetURLPreview = GetURL() & "?"
		Else
			GetURLPreview = GetURL() & "&"
		End If
	Else
		GetURLPreview = GetURL() & "?" & Request.Form & "&"
	End If
	GetURLPreview = GetURLPreview & "Preview"
End Function




Function GetUserWellcome

	Dim vHora, vFecha
	vFecha = Now
	vHora = Hour(vFecha)
	GetUserWellcome = FormatDateTime(vFecha,vbLongDate) & "   " & FormatDateTime(vFecha,vbShortTime) & "Hs."
	GetUserWellcome = GetUserWellcome & "<br>"
	If vHora >= 6 And vHora < 13 Then
		GetUserWellcome = GetUserWellcome & "Buen d�a, " & Session("NombreUsuario")
	ElseIf vHora >= 13 And vHora < 19 Then
		GetUserWellcome = GetUserWellcome & "Buenas tardes, " & Session("NombreUsuario")
	Else
		GetUserWellcome = GetUserWellcome & "Buenas noches, " & Session("NombreUsuario")
	End If
End function

Function ValidSession ()
    If Session("login") <> 1 then
        Response.Redirect ("default.asp")
    End If
End Function

Function ValidUserAction(vModulo, vAccion)
dim vModulo2,vAccion2, User__IDGrupo
vModulo2 = cstr(vModulo)
vAccion2 = cstr(vAccion)
User__IDGrupo = Session("IDGrupo")

If Not Session("Login") = 1 Then
	Response.Redirect("main.asp?BackToURL=" & GetURL())
Else
	Dim oRS
	Set oRS = Server.CreateObject("ADODB.Recordset")
	oRS.ActiveConnection = MM_HelpDesk_STRING
	oRS.Source = "{call dbo.Permisos_TXModuloAccionUsuario ('" + replace(vModulo2,"'", "''") + "','" + replace(vAccion2,"'","''") + "'," + replace(User__IDGrupo, "'", "''") + ")}"
	oRs.open()

	If oRS.EOF Then
		Response.Redirect("mensaje.asp?CodMsg=101&TipoMsg=1")
	End If
	oRS.Close
	Set oRS = nothing

End If

End Function

Function GetAppMsg(vCodMsg)

Select case vCodMsg
case 101
	GetAppMsg="<b>Acceso no permitido.</b><br>No tiene permisos para realizar la operaci�n requerida."
case else
	GetAppMsg="C�digo de mensaje inv�lido."
End select

End Function

function FormatDate(vFecha, vFormato)
dim vDia, vMes, vAnio

if isdate(vFecha) then
    vDia = day(cdate(vFecha))
    if vDia < 10 then
	   vDia = "0" & vDia
	end if
	vMes = month(cdate(vFecha))
    if vMes < 10 then
	   vMes = "0" & vMes
	end if
	vAnio = year(cdate(vFecha))

    select case vFormato
    case "DD/MM/YYYY"
		FormatDate = cstr(vDia) & "/" & cstr(vMes)  & "/" & cstr(vAnio)
    case "MM/DD/YYYY"
		FormatDate = cstr(vMes) & "/" & cstr(vDia)  & "/" & cstr(vAnio)
    case "YYYY/MM/DD"
		FormatDate = cstr(vAnio) & "/" & cstr(vMes) & "/" & cstr(vDia)
	case "MM/YYYY"
		FormatDate = cstr(vMes) & "/" & cstr(vAnio)
	case "DD/MM"
		FormatDate = cstr(vDia) & "/" & cstr(vMes)
    case "YYYYMMDD"
		FormatDate = cstr(vAnio) & cstr(vMes) & cstr(vDia)
	case "YYYY"
		FormatDate = cstr(vAnio)
	case "MM"
		FormatDate = cstr(vMes)
	case "DD"
		FormatDate = cstr(vDia)
	case else
		FormatDate = ""
	end select

else
		FormatDate = ""
end if
End function

function roundUp(x)
   If x > Int(x) then
    roundup = Int(x) + 1
   Else
    roundup = x
   End If
End Function


Function SendMail (From,FromAddress,ToName,ToAddress,CC,CCAddress,BCC, BCCAddress,ReplyTo,ReplyToAddress,Subject,HTMLBody,Attach)
on error resume next

Const cdoAnonymous = 0 'Do not authenticate
Const cdoBasic = 1 'basic (clear-text) authentication
Const cdoNTLM = 2 'NTLM
'
Set ObjMail = CreateObject("CDO.Message")
ObjMail.Subject = Subject
ObjMail.From = From & "<" & FromAddress & ">"
ObjMail.To = ToName & "<" & ToAddress & ">"

If CC <> "" Then
    ObjMail.CC = CC & "<" & CCAddress & ">"
End if

If BCC <> "" Then
    ObjMail.BCC = BCC & "<" & BCCAddress & ">"
End If

If ReplyTo <> "" then
    ObjMail.ReplyTo = ReplyTo & "<" & ReplyToAddress & ">"
End If

'ObjMail.TextBody = BodyText
ObjMail.HTMLBody = HTMLBody

ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing")= 2
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver")="smtp.itdap.com"  'Name or IP of remote SMTP server
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport")= 25 			'Server port
ObjMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoBasic		'Type of authentication, NONE, Basic (Base64 encoded), NTLM
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = "helpdesk@itdap.com"
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "WfgpQ1684mnbsd"
ObjMail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = False

ObjMail.Configuration.Fields.Update
ObjMail.Send

if err.number = 0 then
    SendMail = true
else
    SendMail = false
    response.Write (err.Description &"<br>")
    Response.Write ("FromAddress: " & FromAddress) &"<br>"
    Response.Write ("toAddress: " & toAddress)&"<br>"
    Response.Write ("From2Address: " & From2Address)&"<br>"
    Response.Write ("To2Address: " & To2Address)&"<br>"
    response.end
end if

set ObjMail=nothing
'From=""
'FromAddress=""
'ToName=""
'ToAddress=""
'CC=""
'CCAddress=""
'BCC=""
'BCCAddress=""
'ReplyTo=""
'ReplyToAddress=""
'Subject=""
'HTMLBody=""
'Attach=""

' SQL mail sender
'Set ObjMail = Server.CreateObject ("SMTPsvg.Mailer")

'ObjMail.FromName = FromName
'ObjMail.FromAddress = FromAddress
'ObjMail.Subject = Subject
'ObjMail.BodyText = BodyText
'ObjMail.AddRecipient AddRecipientName,AddRecipient
'ObjMail.ContentType = "text/html"	'header del mail
'ObjMail.AddAttachment Attach		'si queremos adjuntar algun file
'ObjMail.RemoteHost = "svtr88"	'aqui configuramos el servidor SMTP que usamos...
'ObjMail.AddBCC = AddBccName,AddBcc				'y una copia oculta para Pedro

'Envio del mail con chequeo...
'if ObjMail.SendMail then
'if ObjMail.Send then
'    response.write "<BR><font size=""4"" color=""green"">El mail fue enviado con exito</font>"
'else
'    Response.Redirect "Mensaje.asp?Msg=No se ha podido enviar el mail al administrador de Help Desk.&BackToURL=numtickets.asp"
'end if
'
'set ObjMail=nothing

End Function


Function SetDebugOn()

		Response.Expires = 0
		Session("Login") = 1
		Session("NombreUsuario") = "admin"
		Session("FullName") = "admin"
		Session("IDGrupo") = 1
		Session("IDU")=1
		Session("IDCiudad") = 15
		Session("IDIdioma") = 2
		Session("Password") = "admin"

End function



</script>