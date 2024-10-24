Imports Telerik.Web.UI

Public Class ExtentManagement
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            loadRepeater()
        End If
    End Sub

    Private Sub loadRepeater()
        Try
            Dim strSQL = "SELECT ei.UniqueId, ei.Description, ei.AdditionalInfo, eipt.ProcedureTypeId, ISNULL(ei.NEDTerm, '') NEDTerm
                          FROM dbo.ERS_Extent ei
                            INNER JOIN dbo.ERS_ExtentProcedureTypes eipt ON ei.UniqueId = eipt.ExtentId"
            Dim dt = DataAccess.ExecuteSQL(strSQL)

            Dim dtExtent = (From inds In dt.AsEnumerable
                            Group inds("ProcedureTypeId") By UniqueId = inds("UniqueId"), Description = inds("Description"), NEDTerm = inds("NEDTerm") Into g = Group
                            Select UniqueId, Description, NEDTerm, ProcedureTypes = g.ToList)

            rptExtentConfig.DataSource = dtExtent
            rptExtentConfig.DataBind()

            For Each itm As RepeaterItem In rptExtentConfig.Items
                Dim extentId As Integer = CInt(CType(itm.FindControl("ExtentIdHiddenField"), HiddenField).Value)
                Dim procTypes = (From ext In dtExtent
                                 Where ext.UniqueId = extentId
                                 Select ext.ProcedureTypes).FirstOrDefault

                If procTypes.Contains(1) Then 'OGD
                    CType(itm.FindControl("chkOGD"), CheckBox).Checked = True
                End If

                If procTypes.Contains(2) Then 'ERCP
                    CType(itm.FindControl("chkERCP"), CheckBox).Checked = True
                End If

                If procTypes.Contains(3) Then 'COLON
                    CType(itm.FindControl("chkColon"), CheckBox).Checked = True
                End If

                If procTypes.Contains(4) Then 'FLEXI
                    CType(itm.FindControl("chkFlexi"), CheckBox).Checked = True
                End If

                If procTypes.Contains(5) Then 'PROCT
                    CType(itm.FindControl("chkProct"), CheckBox).Checked = True
                End If

                If procTypes.Contains(6) Then 'EUS OGD
                    CType(itm.FindControl("chkEUSOGD"), CheckBox).Checked = True
                End If

                If procTypes.Contains(7) Then 'EUS HPB
                    CType(itm.FindControl("chkEUSHPB"), CheckBox).Checked = True
                End If

                If procTypes.Contains(8) Then 'ENT ANT
                    CType(itm.FindControl("chkENTANT"), CheckBox).Checked = True
                End If

                If procTypes.Contains(9) Then 'ENT RET
                    CType(itm.FindControl("chkENTRetro"), CheckBox).Checked = True
                End If
            Next
        Catch ex As Exception
            Utilities.SetErrorNotificationStyle(RadNotification1, "", "Error loading repeater: " & ex.Message)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub rptExtentConfig_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        Try
            Dim ExtentId As Integer = e.CommandArgument
            Dim extentDescription = CType(e.Item.FindControl("NEDTermRadTextBox"), RadTextBox).Text
            Dim procTypes As New List(Of Integer)
            Dim strSQL = ""

            If Not String.IsNullOrWhiteSpace(extentDescription) Then
                strSQL += "UPDATE ERS_Extent SET Description = " & extentDescription.Trim() & " WHERE UniqueId = " & ExtentId & ";" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkOGD"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 1)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 1);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 1)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 1;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkERCP"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 2)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 2);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 2)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 2;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkColon"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 3)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 3);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 3)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 3;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkFlexi"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 4)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 4);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 4)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 4;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkProct"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 5)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 5);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 5)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 5;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkEUSOGD"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 6)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 6);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 6)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 6;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkEUSHPB"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 7)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 7);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 7)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 7;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkENTANT"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 8)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 8);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 8)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 8;" & vbCrLf
            End If

            If CType(e.Item.FindControl("chkENTRetro"), CheckBox).Checked = True Then
                'insert statement
                strSQL += "IF NOT EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 9)
                                INSERT INTO ERS_ExtentProcedureTypes (ExtentId, ProcedureTypeId) VALUES (" & ExtentId & ", 9);" & vbCrLf
            Else
                'delete statement
                strSQL += "IF EXISTS (SELECT 1 FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 9)
                                DELETE FROM ERS_ExtentProcedureTypes WHERE ExtentId = " & ExtentId & " AND ProcedureTypeId = 9;" & vbCrLf
            End If

            DataAccess.ExecuteScalerSQL(strSQL)


        Catch ex As Exception
            Utilities.SetErrorNotificationStyle(RadNotification1, "", "Error saving extent: " & ex.Message)
            RadNotification1.Show()
        End Try
    End Sub
End Class