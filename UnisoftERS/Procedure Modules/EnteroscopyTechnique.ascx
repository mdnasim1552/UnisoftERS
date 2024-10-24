<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="EnteroscopyTechnique.ascx.vb" Inherits="UnisoftERS.EnteroscopyTechnique" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            toggleOtherTechnique();
        });

        $(document).ready(function () {
            $('.additional-technique-info-text').on('focusout', function () {
                saveProcedureTechnique();
            });

            $('#<%=TattooedCheckBox.ClientID%>').on('change', function () {
                saveInsertionLength();
            });
        });

        function technique_changed(sender, args) {
            toggleOtherTechnique();
            saveProcedureTechnique();
        }

        function toggleOtherTechnique() {
            var text = $find('<%=EnteroscopyTechniqueRadComboBox.ClientID%>').get_text().toLowerCase();

            if (text.toLowerCase() == 'other') {
                $('.other-technique-text-entry').show();
            }
            else {
                $('.other-technique-text-entry').hide();
            }
            removeEmptyValue();
        }

        function saveProcedureTechnique() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.techniqueId = parseInt($find('<%=EnteroscopyTechniqueRadComboBox.ClientID%>').get_value());
            if($find('<%=EnteroscopyTechniqueRadComboBox.ClientID%>').get_text().toLowerCase() === 'other'){
                obj.additionalInfo = $('#<%=OtherTextBox.ClientID%>').val();
            }else{
                obj.additionalInfo = '';
            }
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveEnteroscopyTechnique",
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

        function saveInsertionLength() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.insertionLength = parseInt($find('<%=InsertionDepthRadNumericTextBox.ClientID%>').get_value() || '') || 0;/* edited by mostafiz 4216 */
            obj.tattooed = $('#<%=TattooedCheckBox.ClientID%>').is(':checked');
           
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveInsertionLength",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    autoSaveSuccess = true;
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

        function removeEmptyValue(){
            var techniqueCombo = $find('<%=EnteroscopyTechniqueRadComboBox.ClientID%>');
            var text = $find('<%=EnteroscopyTechniqueRadComboBox.ClientID%>').get_text().toLowerCase();
            var items = techniqueCombo.get_items();
            if(text !== ''){
                for (var i = 0; i < items.get_count(); i++){
                    var item = items.getItem(i);
                    if (item.get_text() === ''){
                        item.set_visible(false);
                    }
                }
            }
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-content">
    <table>
        <tr>
            <td>
                <asp:Label ID="Label3" runat="server" Text="Technique used:" />
            </td>
            <td>
                <telerik:RadComboBox ID="EnteroscopyTechniqueRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" Width="300" AppendDataBoundItems="true" OnClientSelectedIndexChanged="technique_changed">
                    <Items>
                        <telerik:RadComboBoxItem Text="" Value="0" />
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
        <tr class="other-technique-text-entry" style="display: none;">
            <td style="text-align: right;">
                <asp:Label ID="Label5" runat="server" Text="specify other:" />
            </td>
            <td>
                <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="300" CssClass="additional-technique-info-text" />
            </td>
        </tr>
        <tr>
            <td>
                <span>Depth of insertion:</span>
            </td>
            <td>
                <telerik:RadNumericTextBox ID="InsertionDepthRadNumericTextBox" runat="server" Skin="Metro" Width="35" MinValue="0" NumberFormat-DecimalDigits="0"   ClientEvents-OnValueChanged="saveInsertionLength" />cm&nbsp;
                    <asp:CheckBox ID="TattooedCheckBox" runat="server" Text="Tattooed?" />
            </td>
        </tr>
    </table>
</div>
