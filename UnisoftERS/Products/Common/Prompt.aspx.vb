Public Class Prompt
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            Dim reqOption As String = HttpUtility.UrlDecode(Request.QueryString("phraseText"))
            Dim cleanPhraseText = Replace(reqOption, "\n", vbLf)
            Set_Text(cleanPhraseText)
        End If
    End Sub

    Protected Sub Phrase_TextChanged()
        ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "updateANDclose( '" & textareaPrompt.Text.Replace(vbCrLf, "\n").Replace("'", "\'") & "');", True)
    End Sub

    Protected Sub Set_Text(cleanPhraseText As String)
        textareaPrompt.Text = cleanPhraseText
    End Sub

End Class