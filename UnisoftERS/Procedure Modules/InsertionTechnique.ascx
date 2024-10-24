<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="InsertionTechnique.ascx.vb" Inherits="UnisoftERS.InsertionTechnique1" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
        });

        function insertionTechnique_changed(sender, args) {
            var id = args.get_item().get_value();

            saveInsertionTechnique(id);
        }

        function saveInsertionTechnique(id) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.techniqueId = parseInt(id);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureInsertionTechnique",
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
<div class="control-sub-header" id="InsertionTechniqueDiv" runat="server">Insertion technique</div>
<div class="control-content">
    <table>
        <tr>
            <td>Insertion technique
            </td>
            <td>
                <telerik:RadComboBox ID="InsertionTechniqueRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" Width="300" AppendDataBoundItems="true" OnClientSelectedIndexChanged="insertionTechnique_changed">
                    <Items>
                        <telerik:RadComboBoxItem Text="" Value="0" />
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
    </table>
</div>
