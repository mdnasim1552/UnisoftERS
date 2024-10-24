Imports System.Xml.Schema
Imports System.Text

Public Class XmlValidationErrorBuilder
    Private _errors As New List(Of ValidationEventArgs)()

    Public Sub ValidationEventHandler(ByVal sender As Object, ByVal args As ValidationEventArgs)

        Dim type As XmlSeverityType = XmlSeverityType.Warning

        If [Enum].TryParse(Of XmlSeverityType)("Error", type) Then
            If type = XmlSeverityType.[Error] Then _errors.Add(args)
        End If

        'If args.Severity = XmlSeverityType.Warning Then
        '    _errors.Add(args)
        'End If
    End Sub
    Public Function GetErrorList() As Dictionary(Of String, String)
        Dim errorList As New Dictionary(Of String, String)
        Dim type As XmlSeverityType = XmlSeverityType.Warning

        For Each e In _errors
            type = e.Severity
            Dim errorProperty = ""
            Dim errorValue = ""

            If type = XmlSeverityType.[Error] Then
                Dim strStart = ""
                If e.Message.Contains("List of possible elements expected:") Then
                    strStart = e.Message.Substring(e.Message.IndexOf("List of possible elements expected:"))
                    errorValue = "node"
                Else
                    strStart = e.Message
                    errorValue = "value"
                End If

                errorProperty = strStart.Substring(strStart.IndexOf("'") + 1)
                errorProperty = errorProperty.Substring(0, errorProperty.IndexOf("'"))
            ElseIf type = XmlSeverityType.Warning Then
                Dim arr = e.Message.Split("-")
                errorProperty = arr(0).Substring(arr(0).IndexOf("'") + 1)
                errorProperty = errorProperty.Substring(0, errorProperty.IndexOf("'"))

                errorValue = arr(1).Substring(arr(1).IndexOf("'") + 1)
                errorValue = errorValue.Substring(0, errorValue.IndexOf("'"))

            End If
            errorList.Add(errorProperty, errorValue)


        Next

        Return errorList
    End Function

    Public Function GetErrors(ByRef sMessageBody As String) As String
        If _errors.Count <> 0 Then
            Dim AuditMessage As New StringBuilder()
            Dim MessageBody As New StringBuilder()
            MessageBody.Append("The following ")
            MessageBody.Append(_errors.Count.ToString())
            MessageBody.AppendLine(" error(s) were found while validating the XML document against the XSD:")
            MessageBody.AppendLine("<ul>")
            For Each i As ValidationEventArgs In _errors
                MessageBody.AppendLine("<li>")
                AuditMessage.Append(" * ")
                AuditMessage.Append(i.Message)
                MessageBody.Append(i.Message)
                MessageBody.AppendLine("</li>")
            Next
            MessageBody.AppendLine("</ul>")
            sMessageBody = MessageBody.ToString()
            Return AuditMessage.ToString()
        Else
            Return Nothing
        End If
    End Function
End Class
