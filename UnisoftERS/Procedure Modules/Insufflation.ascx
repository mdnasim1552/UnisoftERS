<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Insufflation.ascx.vb" Inherits="UnisoftERS.Insufflation" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {

        });


        function saveInsufflation() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.insufflationId = parseInt($find('<%=InsufflationRadComboBox.ClientID%>').get_value());

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveInsufflation",
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
<div class="control-content">
    <table>
        <tr>
            <td>
                <asp:Label ID="Label3" runat="server" Text="Insufflation gas:" />
            </td>
            <td>
                <telerik:RadComboBox ID="InsufflationRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" Width="300" AppendDataBoundItems="true" OnClientSelectedIndexChanged="saveInsufflation">
                    <Items>
                        
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
    </table>
</div>
