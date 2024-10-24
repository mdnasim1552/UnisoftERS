<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ScopesAndGuides.ascx.vb" Inherits="UnisoftERS.ScopesAndGuides" %>
<telerik:RadScriptBlock runat="server">
    <style>
        .rcbSlide{

            z-index: 9009 !important;
        }
        .label-scope1
        {
             padding-right: 15px;
        }
        .label-scope
        {
             padding-right: 28px;
        }
    </style>
    <script type="text/javascript">
        var autoSaveSuccess;
        var updatedScope1;
        var updatedScope2;
        var isFirstScope = true;
        var scope;
        var isDone = false;
        var autoSelect = false;
        $(window).on('load', function () {
        });

        $(document).ready(function () {
            $('.distal-attachement-text-box-entry').on('focusout', function () {
                saveDistalAttachments();
            });

            $('#<%=ScopeGuideUsedCheckbox.ClientID%>').on('change', function ()
            {
                saveInstrument();
                
            });
            updatedScope1 = $find('<%=cboInstrument1.ClientID%>').get_value();
            if ($find('<%=cboInstrument2.ClientID%>') !== null && $find('<%=cboInstrument2.ClientID%>') !== undefined)
                updatedScope2 = $find('<%=cboInstrument2.ClientID%>').get_value();
        });
        function cancelScope()
        {
            var instrument = $find('<%=cboInstrument1.ClientID%>');
            var instrument1 = $find('<%=cboInstrument2.ClientID%>');
            clearScopeValue();

            if (isFirstScope) {
                selectedDropdown(instrument, updatedScope1);
            }
            else
            {
                if (instrument1 !== null && instrument1 !== undefined) selectedDropdown(instrument1, updatedScope2);
            }
            var window = $find("<%= ScopeWindow.ClientID %>");
            window.close();
  
        }
    function selectManuCombo(comboBox,scope)
    {
          var items = comboBox.get_items();
        if (scope == 0) {
             if (items.get_count() > 0) {
                 var firstItem = items.getItem(0);
                 firstItem.select();
             }
         }
    }
     function selectedDropdown(comboBox, scopes) 
     {
         var items = comboBox.get_items();
         autoSelect = true;

         if (isDone == true) {
             var selectedItem = comboBox.findItemByValue(scope);

             if (selectedItem) {
                 selectedItem.select();
             }
         }
         else
         {
             var selectedItem = comboBox.findItemByValue(scopes);

             if (selectedItem) {
                 selectedItem.select();
             }
         }
       }

        function validateScope()
        {
            if (autoSelect == false) {
                isDone = false;
                var comboBox = $find("<%= cboInstrument1.ClientID %>"); 
                var selectedItem = comboBox.get_selectedItem();
                var selectedValue = selectedItem.get_value();
                isFirstScope = true;
                if (selectedItem)
                {
                    var attributeValue = selectedItem.get_attributes().getAttribute("scope-generation-id");
                    if (!attributeValue && selectedValue != 0)
                    {
                        scope = comboBox.get_value();
                        clearScopeValue();
                        var window = $find("<%= ScopeWindow.ClientID %>");
                        window.show();
                        return false;
                    }
                    else
                    {
                         autoSelect = false;
                        updatedScope1 = $find('<%=cboInstrument1.ClientID%>').get_value();
                        saveInstrument();
                    }
                }
                }
                else
                {
                    autoSelect = false;
                }
        }
        function validateScope1() 
        {
            if(autoSelect == false)
            {
                isDone = false;
            var comboBox = $find("<%= cboInstrument2.ClientID %>");
                var selectedItem = comboBox.get_selectedItem();
                var selectedValue = selectedItem.get_value();
                    isFirstScope = false;
                    if (selectedItem) {
                        var attributeValue = selectedItem.get_attributes().getAttribute("scope-generation-id");
                        if (!attributeValue && selectedValue != 0)
                        {
                            scope = comboBox.get_value();
                            clearScopeValue();
                            var window = $find("<%= ScopeWindow.ClientID %>");
                            window.show();
                        return false;
                    }
                    else
                    {
                             autoSelect = false;
                            updatedScope2 = $find('<%=cboInstrument2.ClientID%>').get_value();
                            saveInstrument();
                        }
                    }
                    }
                else
                {
                    autoSelect = false;
                }
                }
        function saveInstrument() {


            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.instrument1Id = $find('<%=cboInstrument1.ClientID%>').get_value();

            if ('<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>' == '<%=UnisoftERS.ProcedureType.Flexi%>') {

                obj.instrument2Id = 0;
                obj.distalAttachmentId = 0;
                obj.scopeGuideUsed = false;
                obj.techniqueUsed = '';
                obj.techniqueIdx = '';
            }
            else if ('<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>' == '<%=UnisoftERS.ProcedureType.Bronchoscopy%>' || '<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>' == '<%=UnisoftERS.ProcedureType.EBUS%>' || '<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>' == '<%=UnisoftERS.ProcedureType.Transnasal%>') {
                obj.instrument2Id = $find('<%=AccessMethodComboBox.ClientID%>').get_value() == '' ? 0 : $find('<%=AccessMethodComboBox.ClientID%>').get_value();
                obj.distalAttachmentId = $find('<%=DistalAttachmentRadComboBox.ClientID%>') == null ? 0 : $find('<%=DistalAttachmentRadComboBox.ClientID%>').get_value();
                obj.scopeGuideUsed = $('#<%=ScopeGuideUsedCheckbox.ClientID%>') == null ? false : $('#<%=ScopeGuideUsedCheckbox.ClientID%>').is(':checked');
                obj.techniqueUsed = '';
                obj.techniqueIdx = '';
                var techniqueUsedComboBox = $find('<%=TechniqueUsedComboBox.ClientID%>');
                var checkedItems = techniqueUsedComboBox.get_checkedItems();
                if (checkedItems.length > 0) {
                    var selectedTexts = [];
                    var selectedValues = [];

                    for (var i = 0; i < checkedItems.length; i++) {
                        selectedTexts.push(checkedItems[i].get_text());
                        selectedValues.push(checkedItems[i].get_value());
                    }
                    if (selectedTexts.join(", ") !== '') obj.techniqueUsed = selectedTexts.join(", ");
                    if (selectedValues.join(",") !== '') obj.techniqueIdx = selectedValues.join(",");
                }
            }
            else {

                obj.instrument2Id = ($find('<%=cboInstrument2.ClientID%>') !== null && $find('<%=cboInstrument2.ClientID%>') !== undefined) ? $find('<%=cboInstrument2.ClientID%>').get_value() : 0;
                obj.distalAttachmentId = $find('<%=DistalAttachmentRadComboBox.ClientID%>') == null ? 0 : $find('<%=DistalAttachmentRadComboBox.ClientID%>').get_value();
                obj.scopeGuideUsed = $('#<%=ScopeGuideUsedCheckbox.ClientID%>') == null ? false : $('#<%=ScopeGuideUsedCheckbox.ClientID%>').is(':checked');
                obj.techniqueUsed = '';
                obj.techniqueIdx = '';
            }

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveInsturments",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    isDone = true;
                    setRehideSummary();
                    clearScopeValue();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');
                    isDone = false;
                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

        function toggleDistalAttachmentRows(selectedText) {
            //var selectedText = $find('<%#DistalAttachmentRadComboBox.ClientID%>').get_text().toLowerCase();

            if (selectedText.toLowerCase() == 'other') {
                $('.other-distal-text-entry').show();
            }
            else {
                $('.other-distal-text-entry').hide();
                $('#<%=DistalAttachmentOtherRadTextBox.ClientID%>').val("");
            }
        }

        function distal_attachment_changed(sender, args) {
            toggleDistalAttachmentRows(sender.get_text().toLowerCase());

            saveDistalAttachments();
        }

        function openScopeWindow() {
            var window = $find("<%= ScopeWindow.ClientID %>");
            window.show();
        }
        function saveDistalAttachments() {
            var obj = {};
            
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.distalAttachmentId = parseInt($find('<%=DistalAttachmentRadComboBox.ClientID%>').get_value());
            obj.distalAttachmentOther = $('#<%=DistalAttachmentOtherRadTextBox.ClientID%>').val();
            obj.selected = parseInt($find('<%=DistalAttachmentRadComboBox.ClientID%>').get_value()) > 0;

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureDistalAttachment",
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

function addNewItemWithAttribute(comboBox, value, attributeName, attributeValue) 
{
    var item = comboBox.findItemByValue(value);

    if (item) 
    {
        var attributes = item.get_attributes();
        attributes.setAttribute(attributeName, attributeValue);
    } 
}


function CheckForValidPage()
        {
            var valid = Page_ClientValidate("SaveScope");

            if (!valid) {

                $('#masterValDiv', parent.document).html("Scope Generation is required.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
            }
            else
            {
                var obj = {};
                obj.scopeId = scope;
                obj.scopeGenerationId = $find('<%=ScopeGenerationComboBox.ClientID%>').get_value();
                $.ajax({
                    type: "POST",
                    url: "../Procedure.aspx/saveManufactuerGeneration",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (response) {
                        if (response.d == true) {
                            isDone = true;
                            saveInstrument();
                            $find("<%= ScopeWindow.ClientID %>").close();
                            addNewItemWithAttribute($find('<%=cboInstrument1.ClientID%>'),scope,"scope-generation-id",obj.scopeGenerationId);
                             addNewItemWithAttribute($find('<%=cboInstrument2.ClientID%>'),scope,"scope-generation-id",obj.scopeGenerationId);
                        }
                        else
                        {
                            isDone = false;
                            if (isFirstScope) {
                                selectedDropdown($find('<%=cboInstrument1.ClientID%>'), updatedScope1);
                            }
                            else
                            {
                                if ($find('<%=cboInstrument2.ClientID%>') !== null && $find('<%=cboInstrument2.ClientID%>') !== undefined) selectedDropdown($find('<%=cboInstrument2.ClientID%>'), updatedScope2);
                            }
                        }
                    },
                    error: function (x, y, z)
                    {
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
                    }
  
                })
            }
        }
        function scopeManufacturerChanged()
        {
            var manufacturerComboBox = $find('<%= ScopeManufacturerComboBox.ClientID %>');
            var generationComboBox = $find('<%= ScopeGenerationComboBox.ClientID %>');
            var selectedValue = manufacturerComboBox.get_value();
            generationComboBox.get_items().clear();
            var emptyItem = new Telerik.Web.UI.RadComboBoxItem();
            emptyItem.set_text("");
            emptyItem.set_value(0);
            generationComboBox.get_items().add(emptyItem);

            if (selectedValue !== "" && selectedValue !== null) {


                var manufacturerId = selectedValue;

                $.ajax({
                    type: "POST",
                    url: "../Default.aspx/getManufactuerGeneration",
                    data: JSON.stringify({ manufactureId: manufacturerId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var items = JSON.parse(response.d);
                        items.forEach(function (item) {
                            var manipulatedValue = item.Description;
                            var manipulatedKey = item.UniqueId;

                            var comboItem = new Telerik.Web.UI.RadComboBoxItem();
                            comboItem.set_text(manipulatedValue);
                            comboItem.set_value(manipulatedKey);
                            generationComboBox.get_items().add(comboItem);

                        });

                    },
                    error: function (xhr, status, error) {
                        console.error("AJAX Error: ", status, error);
                    }
                });
            }
            selectManuCombo(generationComboBox, 0);
            
        }

        function clearScopeValue()
        {
            var manufacturerComboBox = $find('<%= ScopeManufacturerComboBox.ClientID %>');
            var generationComboBox = $find('<%= ScopeGenerationComboBox.ClientID %>');


            generationComboBox.get_items().clear();

            var emptyItem = new Telerik.Web.UI.RadComboBoxItem();
            emptyItem.set_text("");
            emptyItem.set_value(0);
            generationComboBox.get_items().add(emptyItem);
            selectManuCombo(generationComboBox, 0);
            selectManuCombo(manufacturerComboBox, 0);
        }

    </script>
</telerik:RadScriptBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

<div class="control-content">
    <table class="tblInstruments" runat="server">
        <tr>
            <td>
                <asp:Label ID="Label1" runat="server" Text="1st Scope" />&nbsp;<img src="../../Images/NEDJAG/NEDMand.png" alt="NED/ Mandatory Field" />
            </td>
            <td>
                <telerik:RadComboBox ID="cboInstrument1" runat="server" Skin="Metro" Filter="Contains" DataTextField="ScopeName" Width="200" DataValueField="ScopeId" OnClientSelectedIndexChanged="validateScope" />
            </td>
        </tr>
        <tr id="Scope2Section" runat="server">
            <td>
                <asp:Label ID="Label2" runat="server" Text="2nd Scope" />
            </td>
            <td>
                <telerik:RadComboBox ID="cboInstrument2" runat="server" Skin="Metro" Filter="Contains" DataTextField="ScopeName" Width="200" DataValueField="ScopeId" OnClientSelectedIndexChanged="validateScope1" />
            </td>
        </tr>
        <tr id="trScopeGuide" runat="server" visible="false">
            <td>Scope guide used?</td>
            <td>
                <asp:CheckBox ID="ScopeGuideUsedCheckbox" runat="server" />
                <asp:RadioButtonList ID="rbScopeGuide" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" Visible="false">
                    <asp:ListItem Text="No" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                </asp:RadioButtonList></td>
        </tr>
        <tr id="AccessMethodSection" runat="server" visible="false">
            <td>
                <asp:Label ID="AccessMethodLabel" runat="server" Text="Access Via" />
            </td>
            <td>
                <telerik:RadComboBox ID="AccessMethodComboBox" runat="server" DataValueField="ListItemNo" Skin="Metro" DataTextField="ListItemText" AutoPostBack="false" OnClientSelectedIndexChanged="saveInstrument" Width="200px"/> <%--Added by rony tfs-4345--%>
            </td>
        </tr>
        <tr id="DistalAttachmentSection" runat="server">
            <td>
                <asp:Label ID="DistalAttachmentLabel" runat="server" Text="Distal Attachment" /></td>
            <td>
                <telerik:RadComboBox ID="DistalAttachmentRadComboBox" runat="server" Skin="Metro" Width="200" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="distal_attachment_changed" />
            </td>
        </tr>
        <tr class="other-distal-text-entry" style="display: none;">
            <td>
                <asp:Label ID="Label7" runat="server" Text="specify other:" />
            </td>
            <td>
                <telerik:RadTextBox ID="DistalAttachmentOtherRadTextBox" runat="server" Width="200" CssClass="distal-attachement-text-box-entry" />
            </td>
        </tr>
        <tr id="TechniqueUsedSection" runat="server" visible="false">
            <td>
                <asp:Label ID="Label8" runat="server" Text="Technique Used:" />
            </td>
            <td>
                <telerik:RadComboBox ID="TechniqueUsedComboBox" runat="server" Skin="Metro" Width="300" OnClientLoad=""
                     DataTextField="Description" DataValueField="UniqueId" CheckBoxes="True" OnClientDropDownClosed="saveInstrument">
                    <Items>
                        <telerik:RadComboBoxItem Text="Radial-endobronchial ultrasound (R-EBUS)" Value="1" />
                        <telerik:RadComboBoxItem Text="Endobronchial ultrasonography and guide sheath (EBUS-GS)" Value="2" />
                        <telerik:RadComboBoxItem Text="Virtual bronchoscopic navigation (VBN)" Value="3" />
                        <telerik:RadComboBoxItem Text="Electromagnetic navigation bronchoscopy (ENB)" Value="4" />
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="padding-bottom: 10px;" />
        </tr>
    </table>
</div>
<telerik:RadWindowManager ID="AddNewScpRadWindowManager" runat="server" ShowContentDuringLoad="false" VisibleStatusbar="false"
                                            Style="z-index: 8003" AutoClose="false" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
<Windows>
<telerik:RadWindow ID="ScopeWindow" runat="server"  Title="Add Scope Details" Width="400px" Height="190px"
    KeepInScreenBounds="true" ReloadOnShow="true" VisibleStatusbar="false" ShowContentDuringLoad="true" OnClientClose="cancelScope">
    <ContentTemplate>
        <div style="padding: 20px;">
            <asp:Label runat="server" Text="Manufacturer" Width="140px" CssClass="label-scope1"  AssociatedControlID="ScopeManufacturerComboBox" />
                            
            <telerik:RadComboBox 
                    ID="ScopeManufacturerComboBox" 
                    runat="server" 
                    DataTextField="Description" 
                    DataValueField="UniqueId"
                    ReadOnly="false"
                    OnClientSelectedIndexChanged ="scopeManufacturerChanged" 
                    AutoPostBack="false" 
                    Skin="Windows7" />
            
            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" CssClass="aspxValidator"
                ControlToValidate="ScopeManufacturerComboBox" EnableClientScript="true" Display="Dynamic"
                ErrorMessage="Scope manufacturer is required" Text="*" ToolTip="This is a required field"
                ValidationGroup="SaveScope">
            </asp:RequiredFieldValidator>

            <br /><br />

            <asp:Label runat="server" Text="Generation" Width="140px" CssClass="label-scope" AssociatedControlID="ScopeGenerationComboBox" />
           
                  <telerik:RadComboBox 
                            ID="ScopeGenerationComboBox" 
                            runat="server" 
                            DataTextField="Description" 
                            DataValueField="UniqueId"
                            AutoPostBack="false" 
                            ReadOnly="false" 
                            Skin="Windows7" />

            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" CssClass="aspxValidator"
                ControlToValidate="ScopeGenerationComboBox" EnableClientScript="true" Display="Dynamic"
                ErrorMessage="Scope generation is required" Text="*" ToolTip="This is a required field"
                ValidationGroup="SaveScope">
            </asp:RequiredFieldValidator>

            <br /><br />

            <telerik:RadButton ID="btnSaveScope" runat="server" Text="Save"  Skin="Metro"
                ValidationGroup="SaveScope" AutoPostBack="false" OnClientClicked="CheckForValidPage" CausesValidation="true"/>
            <telerik:RadButton ID="btnCancelScope" runat="server" AutoPostBack="false" Text="Cancel" OnClientClicked="cancelScope" 
                CausesValidation="false" Skin="Metro" />
        </div>
    </ContentTemplate>
</telerik:RadWindow>
</Windows>
 </telerik:RadWindowManager>