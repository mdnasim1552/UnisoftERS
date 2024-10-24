<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="DamagingDrugs.ascx.vb" Inherits="UnisoftERS.DamagingDrugs" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
        var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
        $(document).ready(function () {
            toggleAntiCoagNotification();
            togglePotentialSignificantDrugNotification();<%--added by rony tfs-4171--%>
            $('#<%=AntiCoagRadioButtonList.ClientID%> input').on('change', function () {            
                toggleAntiCoagNotification();
                var potentialDrugStatus = "";
                var selectedItem = $('#<%=AntiCoagRadioButtonList.ClientID%> input:checked').val();
                var potentialSelectedItem = $('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input:checked').val();

                if (potentialSelectedItem === undefined) {
                    potentialDrugStatus = "null";
                } else {
                    potentialDrugStatus = potentialSelectedItem
                }
                saveAntiCoagDrugStatus(selectedItem, potentialDrugStatus);
            });
            <%--added by rony tfs-4171--%>
            $('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input').on('change', function () {
                togglePotentialSignificantDrugNotification();
                var drugStatus = "";
                var selectedItem = $('#<%=AntiCoagRadioButtonList.ClientID%> input:checked').val();
                var potentialSelectedItem = $('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input:checked').val();

                if (selectedItem === undefined) {
                    drugStatus = "null";
                } else {
                    drugStatus = selectedItem
                }                
                saveAntiCoagDrugStatus(drugStatus, potentialSelectedItem);
            });
            
        });        
        function toggleAntiCoagNotification() {
            if ($('#<%=AntiCoagRadioButtonList.ClientID%> input:checked').length > 0) {
                var selectedItem = $('#<%=AntiCoagRadioButtonList.ClientID%> input:checked');
                var drugStatus = (selectedItem.val() == '0' ? false : true);
                if (drugStatus == true) {
                    $('.anti-coag-notification').show();
                }
                else {
                    $('.anti-coag-notification').hide();
                    clearAntiCoag();
                }
            }
            else {
                $('.anti-coag-notification').hide();
                clearAntiCoag();
            }
        }
         <%--added by rony tfs-4171--%>
        function saveAntiCoagDrugStatus(drugStatus, potentialDrugStatus) { 
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.drugStatus = drugStatus;
            obj.potentialSignificantStatus = potentialDrugStatus;

            if (!drugStatus) {
                var radComboBox = $find('<%=AntiCoagDrugsRadComboBox.ClientID%>')
                radComboBox.clearSelection();
            }
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveAntiCoagDrugStatus",
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
        function saveDamagingDrug(sender) {
            var antiCoag = 0;
            var newItem = '';
            var sectionName = '';
            var potentialDrugStatus = "";
            var antiCoagOtherText = "";

            if (sender.get_id().split('_').pop() == 'AntiCoagDrugsRadComboBox') {
                antiCoag = 1;
                sectionName = 'Anti-coag drugs';
                antiCoagOtherText = $find('<%=OtherTextBox.ClientID%>').get_value();
            }
            <%--added by rony tfs-4171--%>
            var potentialSelectedItem = $('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input:checked').val();
            if (potentialSelectedItem === undefined) {
                potentialDrugStatus = "null";
            } else {
                potentialDrugStatus = potentialSelectedItem
            }


            var checkedItems = sender.get_checkedItems();
            if (checkedItems.length < 1) { $("#AntiCoagOtherText").hide(); $find('<%=OtherTextBox.ClientID%>').set_value(''); }
            var ids = [];
            for (var i = 0; i < checkedItems.length; i++) {
                var currentVal = checkedItems[i]._properties._data.value;
                var currentText = checkedItems[i]._text;
                if (currentText === 'Other' && sectionName === 'Anti-coag drugs') $("#AntiCoagOtherText").show();
                if (currentVal == -55) {
                    //return;
                    continue;
                } else if (currentVal == -99) {
                    newItem = checkedItems[i]._properties._data.text;
                } else {
                    ids.push(currentVal);
                }
            }
            saveDamagingDrugHelper(ids, antiCoag, sectionName, newItem, potentialDrugStatus, antiCoagOtherText)
        }
        function comboLoadAntiCoag(sender) {
            var antiCoagComboBox = $find('<%= AntiCoagDrugsRadComboBox.ClientID %>');
            var antiCoagCheckedItems = antiCoagComboBox.get_items();
            var antiCoagCheckedCount = antiCoagCheckedItems.get_count();
            for (var i = 0; i < antiCoagCheckedCount; i++) {
                var item = antiCoagCheckedItems.getItem(i);
                if (item.get_checked() && item.get_text() === 'Other') {
                    $("#AntiCoagOtherText").show();
                }
            }
            if ('<%= Session("IsAdmin") %>' == 'True') {
                var itemCount = sender.get_items().get_count();
                var item = sender.get_items().getItem(itemCount - 1),
                checkBoxElement = item.get_checkBoxElement(),
                itemParent = checkBoxElement.parentNode;
                itemParent.removeChild(checkBoxElement);
            } else return;
        }
        <%--added by rony tfs-4171--%>
        function togglePotentialSignificantDrugNotification() {
            if ($('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input:checked').length > 0) {
                var selectedItem = $('#<%=PotentialSignificantDrugRadioButtonList.ClientID%> input:checked');
                var drugSHowHideStatus = (selectedItem.val() == '0' ? false : true);

                if (drugSHowHideStatus == true) {
                    $('.potential-significan-drug-notification').show();
                }
                else {
                    $('.potential-significan-drug-notification').hide();
                    resetPotentialSignificantDrugComboBox();
                }
            }
            else {
                $('.potential-significan-drug-notification').hide();
                resetPotentialSignificantDrugComboBox();
            }
        }
        function resetPotentialSignificantDrugComboBox() {
            var comboBox = $find('<%= DamagingDrugsComboBox.ClientID %>');
            var items = comboBox.get_items();
            var itemCount = items.get_count();

            for (var i = 0; i < itemCount; i++) {
                var item = items.getItem(i);
                item.set_checked(false);
            }

            comboBox.clearSelection();
            comboBox.set_text('');
        }
        function clearAntiCoag(){
            var radComboBox = $find('<%=AntiCoagDrugsRadComboBox.ClientID%>')
            radComboBox.clearSelection();

            var comboBox = $find('<%= AntiCoagDrugsRadComboBox.ClientID %>');
            var items = comboBox.get_items();
            var itemCount = items.get_count();

            for (var i = 0; i < itemCount; i++) {
                var item = items.getItem(i);
                item.set_checked(false);
            }
            $("#AntiCoagOtherText").hide();
            $find('<%=OtherTextBox.ClientID%>').set_value('');
            comboBox.clearSelection();
            comboBox.set_text('');
        }
        function antiCoagItemChecked(sender, args) {
            var item_text = args.get_item().get_text();
            var item_value = args.get_item().get_value();
            if (item_text === 'Add new' && parseInt(item_value) === -55) {
                if (typeof AddNewItemPopUp === 'function') {
                    AddNewItemPopUp(<%=AntiCoagDrugsRadComboBox.ClientID%>, true, true);
                } else {
                    window.parent.AddNewItemPopUp(<%=AntiCoagDrugsRadComboBox.ClientID%>, true, true);
                }
            } else if (item_text === 'Other') {
                var antiCoagOther = args._item._properties._data.checked;
                if (antiCoagOther) {
                    $("#AntiCoagOtherText").show();
                } else {
                    $("#AntiCoagOtherText").hide();
                    $find('<%=OtherTextBox.ClientID%>').set_value('');
                }
            }
        }
        function saveDamagingDrugOtherText(sender) {
            var antiCoag = 1;
            var newItem = '';
            var sectionName = 'Anti-coag drugs';
            var potentialDrugStatus = "";
            var antiCoagOtherText = sender.get_value();
            var checkedItems = $find("<%= AntiCoagDrugsRadComboBox.ClientID %>").get_checkedItems();
            var ids = [];
            for (var i = 0; i < checkedItems.length; i++) {
                var currentVal = checkedItems[i]._properties._data.value;
                if (currentVal == -55) {
                    //return;
                    continue;
                } else if (currentVal == -99) {
                    newItem = checkedItems[i]._properties._data.text;
                } else {
                    ids.push(currentVal);
                }
            }

            saveDamagingDrugHelper(ids, antiCoag, sectionName, newItem, potentialDrugStatus, antiCoagOtherText);
        }
        function saveDamagingDrugHelper(ids, antiCoag, sectionName, newItem, potentialDrugStatus, antiCoagOtherText) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.drugId = ids.join(',');
            obj.antiCoag = antiCoag;
            obj.sectionName = sectionName;
            obj.newText = newItem;
            obj.potentialSignificantStatus = potentialDrugStatus; <%--added by rony tfs-4171--%>
            obj.antiCoagOtherText = antiCoagOtherText;
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveDamagingDrug",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (response) {
                    setRehideSummary();
                    var newDrugId = response.d;
                    var comboBox = $find("<%= AntiCoagDrugsRadComboBox.ClientID %>");

                    var checkedItems = comboBox.get_checkedItems();
                    for (var i = 0; i < checkedItems.length; i++) {
                        var currentVal = checkedItems[i]._properties._data.value;
                        if (currentVal == -99) {
                            var newValue = newDrugId;
                            if(newValue !== 0) checkedItems[i]._properties._data.value = newValue;
                        }
                    }
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
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
<div class="control-section-header abnorHeader">Medication</div>
<div class="control-content">
    
    <table cellspacing="1" cellpadding="1">
        <tr>
            <td colspan="3">Is the patient taking anti-coagulant or anti-platelet medication?&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;             
                 <asp:RadioButtonList ID="AntiCoagRadioButtonList" runat="server" Style="display: inline; vertical-align: middle;margin-left: -3px;" Skin="Windows7" RepeatLayout="Flow" RepeatDirection="Horizontal" RepeatColumns="2">
                    <asp:ListItem Text="No" Value="0" />
                    <asp:ListItem Text="Yes" Value="1" />
                </asp:RadioButtonList>&nbsp;
            </td>
        </tr>
        <tr class="anti-coag-notification">
            <td colspan="3">
                <span style="color: red; font-style: italic;">* You must record medication/allergies for this procedure when the patient is taking anti-coagulant or anti-platelet medication.</span><br />
            </td>
        </tr>
        <tr class="anti-coag-notification">
             <td>
                <label>
                    Anit-Coagulant & Anti- Platelet Drugs</label>
            </td>
            <td style="min-width: 302px;">
                <telerik:RadComboBox ID="AntiCoagDrugsRadComboBox" runat="server" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" DataTextField="Description" DataValueField="UniqueId"
                    Width="100%"  Skin="Windows7" OnClientDropDownClosed="saveDamagingDrug" OnClientLoad="comboLoadAntiCoag" OnClientItemChecked="antiCoagItemChecked"/>
            </td>
            <td id="AntiCoagOtherText" style="display: none;">
                <telerik:RadTextBox ID="OtherTextBox" runat="server" ClientEvents-OnValueChanged="saveDamagingDrugOtherText" />
            </td>
        </tr>
        <%--added by rony tfs-4171--%>         
        <tr>
            <td style="width:352px;">Is the patient taking potentially significant drugs?</td>
            <td>
                 <asp:RadioButtonList ID="PotentialSignificantDrugRadioButtonList" runat="server" Style="display: inline; vertical-align: middle;margin-left: -3px;" Skin="Windows7" RepeatLayout="Flow" RepeatDirection="Horizontal" RepeatColumns="2">
                    <asp:ListItem Text="No" Value="0" />
                    <asp:ListItem Text="Yes" Value="1" />
                </asp:RadioButtonList>
            </td>
        </tr> 
        <tr colspan="3" class="potential-significan-drug-notification">
            <td class="potential-significan-drug-notification">
                <label>Potential signiicant drugs</label>                    
            </td>
            <td>
                <telerik:RadComboBox ID="DamagingDrugsComboBox" runat="server" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" DataTextField="Description" DataValueField="UniqueId" Width="100%" Skin="Windows7" OnClientDropDownClosed="saveDamagingDrug" />
            </td>
        </tr>        
    </table>
</div>
<telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
    <Windows>
        <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
            KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
            <ContentTemplate>
                <table cellspacing="3" cellpadding="3" style="width: 100%">
                    <tr>
                        <td>
                            <br />
                            <div class="left">
                                <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                &nbsp;&nbsp;
                                <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                            </div>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
