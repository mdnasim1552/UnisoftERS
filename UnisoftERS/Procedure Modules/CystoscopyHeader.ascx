<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="CystoscopyHeader.ascx.vb" Inherits="UnisoftERS.CystoscopyHeader" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
          
              $('.ProcedureType input').on('change', function () {
                 
                saveCystoscopyHeader()

            })
        })
      

         function CystoscopyTypeChange(sender, eventArgs) {
            saveCystoscopyHeader()

        }
        function saveCystoscopyHeader() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            //alert($("#<%=CystoscopyType.ClientId%>").val())
            //alert($("#<%=CystoscopyProcedureType.ClientId%>").val())
            var CystoscopyTypeId=$("#<%=CystoscopyType.ClientId%>").val()
            var CystoscopyProcedureType =$("#<%=CystoscopyProcedureType.ClientId%> input:radio:checked").val()
            obj.CystoscopyTypeId = CystoscopyTypeId;
            obj.CystoscopyProcedureType = CystoscopyProcedureType;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveCystoscopyHeader",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

       

    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
 <div id="CystoscopyHeaderDiv" runat="server" >
                        <div style="margin-top: 10px; margin-left: 10px" id="CystoscopyTypeDiv">
                            <telerik:RadLabel ID="CystoscopyTypeLabel" runat="server" Text="Cystoscopy Type: "></telerik:RadLabel>
                            <telerik:RadComboBox ID="CystoscopyType" runat="server" onclientselectedindexchanged="CystoscopyTypeChange">
                            </telerik:RadComboBox>
                        </div>
                        <div style="margin-top: 10px; margin-left: 10px" id="CystoscopyProcedureTypeDiv">
                            <table>
                                <tr>
                                    <td>
                                        <telerik:RadLabel ID="CystoscopyProcedureTypeLabel" runat="server" Text="Cystoscopy Procedure Type: "></telerik:RadLabel>
                                    </td>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="CystoscopyProcedureType" CssClass="ProcedureType" RepeatDirection="Horizontal" >
                                            <asp:ListItem Text="Flexi" Value="Flexi" />
                                            <asp:ListItem Text="Rigid" Value="Rigid" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                            </table>

                        </div>
                    </div>