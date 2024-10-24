Public Class ProcedureExtent
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))


        If Not (procType = CInt(ProcedureType.Colonoscopy) Or procType = CInt(ProcedureType.Proctoscopy) Or procType = CInt(ProcedureType.Sigmoidscopy) Or procType = CInt(ProcedureType.Retrograde)) Then
            ProcLowerExtent.Visible = False
        End If

        If Not (procType = CInt(ProcedureType.Gastroscopy) Or procType = CInt(ProcedureType.Transnasal) Or procType = CInt(ProcedureType.EUS_OGD) Or procType = CInt(ProcedureType.EUS_HPB) Or procType = CInt(ProcedureType.Antegrade) Or procType = CInt(ProcedureType.ERCP)) Then
            ProcUpperExtent.Visible = False
        End If
    End Sub

End Class