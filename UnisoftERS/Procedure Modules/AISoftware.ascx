<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="AISoftware.ascx.vb" Inherits="UnisoftERS.AISoftware" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
        });

        $(document).ready(function () {
            $('.AI-text-box-entry').on('focusout', function () {
                saveAISoftware();
            });
        });

        function saveAISoftware() {
            if ('<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>' == '<%=UnisoftERS.ProcedureType.Flexi%>') {
                return true
            }
            var selectedText = $find('<%=AISoftwareRadComboBox.ClientID%>').get_text().toLowerCase();

            if (selectedText.includes('none')) {
                $('#<%=AISoftwareOtherTextBox.ClientID%>').val('');
                $('#<%=AISoftwareNameTextBox.ClientID%>').val('');
                $('#<%=AIOtherSoftwareNameTextBox.ClientID%>').val('');

            }
            else if (selectedText.includes('and')) {
                $('#<%=AISoftwareOtherTextBox.ClientID%>').val('');

            }
            else if (selectedText.includes('other')) {
                $('#<%=AIOtherSoftwareNameTextBox.ClientID%>').val('');
            }
            else {
                $('#<%=AISoftwareOtherTextBox.ClientID%>').val('');
            }

            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.AISoftwareId = parseInt($find('<%=AISoftwareRadComboBox.ClientID%>').get_value());
            obj.AISoftwareOther = $('#<%=AISoftwareOtherTextBox.ClientID%>').val();
            obj.AISoftwareName1 = $('#<%=AISoftwareNameTextBox.ClientID%>').val();
            obj.AISoftwareName2 = $('#<%=AIOtherSoftwareNameTextBox.ClientID%>').val();

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureAISoftware",
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
            })
        }

        function toggleAISoftwareRows(selectedText) {
            //var selectedText = $find('<%#AISoftwareRadComboBox.ClientID%>').get_text().toLowerCase();

            if (selectedText != null) {
                //toggle required fields
                if (selectedText.includes('none')) {
                    $('.cade-software-row').hide();
                    $('.other-software-row').hide();
                    $('.AI-other-text-entry').hide();
                }
                else if (selectedText.includes('and')) {
                    //request names for both
                    $('.cade-software-row').show();
                    $('.other-software-row').show();
                    $('.AI-other-text-entry').hide();

                }
                else if (selectedText.includes('other')) {
                    $('.cade-software-row').show();
                    $('.AI-other-text-entry').show();
                    $('.other-software-row').hide();
                }
                else {
                    $('.cade-software-row').show();
                    $('.AI-other-text-entry').hide();
                    $('.other-software-row').hide();
                }
            }
        }

        function AI_software_changed(sender, args) {
            toggleAISoftwareRows(sender.get_text().toLowerCase());

            saveAISoftware();
        }


    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

<div class="control-content" runat="server" id="AISoftwareContent">
    <table class="tblInstruments" runat="server">
        <tr id="AISoftwareSection" runat="server">
            <td>
                <asp:Label ID="Label3" runat="server" Text="AI Software used:" />
            </td>
            <td>
                <telerik:RadComboBox ID="AISoftwareRadComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="AI_software_changed" Width="300" />
            </td>
        </tr>
        <tr class="AI-other-text-entry" style="display: none;">
            <td>
                <asp:Label ID="Label5" runat="server" Text="specify other:" />
            </td>
            <td>
                <telerik:RadTextBox ID="AISoftwareOtherTextBox" runat="server" Width="200" CssClass="AI-text-box-entry" />
            </td>
        </tr>
        <tr>
        </tr>
        <tr class="cade-software-row" style="display: none;">
            <td>
                <asp:Label ID="Label4" runat="server" Text="AI software name:" />
            </td>
            <td>
                <telerik:RadTextBox ID="AISoftwareNameTextBox" runat="server" Width="200" CssClass="AI-text-box-entry" />
            </td>
        </tr>
        <tr class="other-software-row" style="display: none;">
            <td>
                <asp:Label ID="Label6" runat="server" Text="Other software name:" />
            </td>
            <td>
                <telerik:RadTextBox ID="AIOtherSoftwareNameTextBox" runat="server" Width="200" CssClass="AI-text-box-entry" />
            </td>
        </tr>
    </table>
</div>
