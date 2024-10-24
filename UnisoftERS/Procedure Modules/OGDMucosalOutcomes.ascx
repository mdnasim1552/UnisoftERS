<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="OGDMucosalOutcomes.ascx.vb" Inherits="UnisoftERS.OGDMucosalOutcomes" %>
<style type="text/css">
   
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            //toggleOtherCleaning();
        });

        $(document).ready(function () {
            // 4364 -starts
            $('.additional-cleaning-info-text').on('focusout', function () {
                var selected = true;
                var dropdown = $find("<%= MucosalCleaningRadComboBox.ClientID %>");
                var checkedItems = dropdown.get_checkedItems();
                for (var i = 0; i < checkedItems.length; i++) {
                    if (checkedItems[i].get_text().toLowerCase() === 'other') {
                        saveMucosalCleaning(checkedItems[i].get_value(), selected);
                        break;
                    }
                }               
            });
            // 4364 -end
            // edited by mostafiz 3566
            var dropdown = $find("<%= MucosalCleaningRadComboBox.ClientID %>");
            $(dropdown.get_dropDownElement()).on('mouseleave', function () {
                dropdown.hideDropDown();
            });
            // edited by mostafiz 3566
        });

        function saveVisualisation() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.mucosalVisualisationId = $find('<%=MucosalVisualisationRadComboBox.ClientID%>').get_value();

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveMucosalVisualisation",
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

        function mucosalcleaning_changed(sender, args) {
            var id = args.get_item().get_value();
            var itemText = args.get_item().get_text();
            var selected = args.get_item().get_checked(); 

            toggleOtherCleaning(itemText, selected);

            if (itemText.toLowerCase() != 'other') {
                saveMucosalCleaning(id, selected);
            }

            uncheckOtherCheckboxes(sender, itemText);
             
        }



        function uncheckOtherCheckboxes(comboBox, itemText) {
           let comboItems = comboBox.get_items();
            if (itemText.toLowerCase() == 'none') {
                for (let i = 1; i < comboItems.get_count(); i++) {
                    let item = comboItems.getItem(i);          
                        item.set_checked(false);
                }
            }
            else {           
                comboItems.getItem(0).set_checked(false);
            }

        }


        function toggleOtherCleaning(text, selected) {
            if (text.toLowerCase() == 'other' && selected == true) {
                $('.other-cleaning-text-entry').show();
            }
            else {
                $('.other-cleaning-text-entry').hide();            
            }
        }

        function saveMucosalCleaning(id, selected) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.mucosalCleaningId = parseInt(id);
            obj.additionalInfo = $('#<%=OtherTextBox.ClientID%>').val();
            obj.selected = selected;
         $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveMucosalCleaning",
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
            <td style="width:150px;">
                <span>Mucosal Visualisation </span>
            </td>
            <td>
                <telerik:RadComboBox ID="MucosalVisualisationRadComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="saveVisualisation" AppendDataBoundItems="true" Width="300">
                    <Items>
                        
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
        <tr>
            <td>
                <span>Mucosal Cleaning</span>
            </td>
            <td>
                <telerik:RadComboBox ID="MucosalCleaningRadComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" Width="300" CheckBoxes="true" OnClientItemChecked="mucosalcleaning_changed">
                    <Items>
                        
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
        <tr class="other-cleaning-text-entry" style="display: none;">
            <td>
                <span>Specify other</span>
            </td>
            <td>
                <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="300" CssClass="additional-cleaning-info-text" />
            </td>
        </tr>
    </table>
</div>
