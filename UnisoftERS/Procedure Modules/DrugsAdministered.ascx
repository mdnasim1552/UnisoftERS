<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="DrugsAdministered.ascx.vb" Inherits="UnisoftERS.DrugsAdministered" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
            $('.broncho-drug-selection').on('change', function ()
            {
                var checkBox = $('#<%=LignocaineSprayCheckBox.ClientID%>').is(':checked');
                var textBox = $find('<%=LignocaineSprayTextBox.ClientID%>');               

                if (checkBox) {
                    textBox.set_value(1);
                } else
                {
                    textBox.set_value("");
                }
                saveBronchoDrugs();
            });
            //Added by rony tfs-4328
            $('.sumLignocaineClass').on('change', function () {                
                sumValuesByClass();
            });
            $("#<%=LignocaineSprayPercentageRadioButtonList.ClientID%> input").change(function () {                
                saveBronchoDrugs();
            });
        });
        //Added by rony tfs-4328
        function sumValuesByClass() {
            var elements = document.getElementsByClassName('sumLignocaineClass');
            var total = 0;
            for (var i = 0; i < elements.length; i++) {
                var numericTextBox = $find(elements[i].id);
                var value = numericTextBox.get_value();
                total += (value || 0);  
            }
            $find('<%= LignocaineTotalTextBox.ClientID %>').set_value(total.toFixed(2));
        }
        
        function saveBronchoDrugs()
        {
            var obj = {};
            obj.lignocaineSprayTotal = $find('<%=LignocaineSprayTextBox.ClientID%>').get_value();
            obj.lignocaineSprayPercentage = $('#<%=LignocaineSprayPercentageRadioButtonList.ClientID%> input:checked').val(); //Added by rony tfs-4328

            if (obj.lignocaineSprayTotal == "")
            {
                $('#<%=LignocaineSprayCheckBox.ClientID%>').prop('checked', false);

            }
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.effectOfSedation = null;<%--($('#<%=EffectOfSedationRadioButtonList.ClientID%> input:checked').length > 0 ? $('#<%=EffectOfSedationRadioButtonList.ClientID%> input:checked').val() : null);--%>
            obj.lignocaineSpray = $('#<%=LignocaineSprayCheckBox.ClientID%>').is(':checked');
            obj.lignocaineGel = $('#<%=LignocaineGelCheckBox.ClientID%>').is(':checked');
            obj.lignocaineViaScope1pc = $find('<%=LignocaineViaScope1pcTextBox.ClientID%>').get_value();
            obj.lignocaineViaScope2pc = $find('<%=LignocaineViaScope2pcTextBox.ClientID%>').get_value();
            obj.lignocaineViaScope4pc = $find('<%=LignocaineViaScope4pcTextBox.ClientID%>').get_value();
            obj.lignocaineNebuliser2pc = $find('<%=LignocaineNebuliser2pcTextBox.ClientID%>').get_value();
            obj.lignocaineNebuliser4pc = $find('<%=LignocaineNebuliser4pcTextBox.ClientID%>').get_value();
            obj.lignocaineTranscricoid2pc = $find('<%=LignocaineTranscricoid2pcTextBox.ClientID%>').get_value();
            obj.lignocaineTranscricoid4pc = $find('<%=LignocaineTranscricoid4pcTextBox.ClientID%>').get_value();
            obj.lignocaineBronchial1pc = $find('<%=LignocaineBronchial1pcTextBox.ClientID%>').get_value();
            obj.lignocaineBronchial2pc = $find('<%=LignocaineBronchial2pcTextBox.ClientID%>').get_value();
            obj.supplyOxygen = $('#<%=SupplyOxygenCheckBox.ClientID%>').is(':checked');
            obj.supplyOxygenPercentage = $find('<%=SupplyOxygenPercentageTextBox.ClientID%>').get_value();
            obj.nasal = $find('<%=NasalTextBox.ClientID%>').get_value();
            obj.spO2Base = $find('<%=SpO2BaseTextBox.ClientID%>').get_value();
            obj.spO2Min = $find('<%=SpO2MinTextBox.ClientID%>').get_value();




            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/SaveBronchoDrugs",
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

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<asp:ObjectDataSource ID="DrugsObjectDataSource" runat="server" SelectMethod="GetBronchoPremedication" TypeName="UnisoftERS.OtherData">
    <SelectParameters>
        <asp:Parameter Name="procedureId" DbType="String" />
    </SelectParameters>
</asp:ObjectDataSource>

<%--<div class="control-sub-header" id="Div1" runat="server">Effect of sedation</div>
<table style="padding: 15px;">
    <tr>
        <td>
            <asp:RadioButtonList ID="EffectOfSedationRadioButtonList" runat="server" CellSpacing="3" CellPadding="3" CssClass="broncho-drug-selection">
                <asp:ListItem Value="1" Text="No Sedation"></asp:ListItem>
                <asp:ListItem Value="2" Text="Moderate Sedation/Analgesia ('Conscious Sedation')"></asp:ListItem>
                <asp:ListItem Value="3" Text="Minimal Sedation/Anoxiolysis"></asp:ListItem>
                <asp:ListItem Value="4" Text="Deep Sedation/Analgesia"></asp:ListItem>
            </asp:RadioButtonList>
        </td>
        <td valign="bottom" align="right">
            <telerik:RadButton ID="GuidelinesButton" runat="server" Text="Guidelines for Sedation" OnClientClicked="openGuidelinesPopUp" Skin="Windows7" Icon-PrimaryIconCssClass="rbHelp" AutoPostBack="false" />
        </td>
    </tr>
</table>--%>

<div class="control-sub-header" id="Div2" runat="server">Local anaesthesia - Lidocaine / Lignocaine</div>
<table cellpadding="2" cellspacing="2" style="margin-top: 5px; padding: 15px;">
    <tr>
        <%--Added by rony tfs-4328--%>
        <td width="130px"><asp:CheckBox ID="LignocaineSprayCheckBox" runat="server" Text="Sprays" CssClass="broncho-drug-selection" /></td>
        <td colspan="2">
            <asp:RadioButtonList ID="LignocaineSprayPercentageRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" style="margin-left:-6px;">  
                <asp:ListItem Text="5%" Value="5" />
                <asp:ListItem Text="10%" Value="10" Selected="True" />
            </asp:RadioButtonList>
            <telerik:RadNumericTextBox ID="LignocaineSprayTextBox" runat="server" Width="65" Skin="Windows7" minValue="1" CssClass="broncho-drug-textbox" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
        </td>
        <td style="width: 20px;"></td>
        <td width="130px">1% to larynx via scope</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineViaScope1pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
        </td>
        <td>mls</td>
        <td style="width: 20px;"></td>
        <td width="110px">2% given  traNscRicoid</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineTranscricoid2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
        </td>
        <td>mls</td>
    </tr>
    <tr>
        <td colspan="3">
            <asp:CheckBox ID="LignocaineGelCheckBox" runat="server" Text="gel" CssClass="broncho-drug-selection" /></td>
        <td style="width: 20px;"></td>
        <td>2% to larynx via scope</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineViaScope2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
        <td style="width: 20px;"></td>
        <td>4% given  traNscRicoid</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineTranscricoid4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
    </tr>
    <tr>
        <td width="100px">2% by nebuliser</td>
        <td>
            <telerik:RadNumericTextBox ID="LignocaineNebuliser2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
        <td style="width: 20px;"></td>
        <td>4% to larynx via scope</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineViaScope4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
        <td style="width: 20px;"></td>
        <td>1% to bronchial tree</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineBronchial1pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
    </tr>
    <tr>
        <td>4% by nebuliser</td>
        <td>
            <telerik:RadNumericTextBox ID="LignocaineNebuliser4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
        <td style="width: 20px;"></td>
        <td></td>
        <td style="width: 52px"></td>
        <td></td>
        <td style="width: 20px;"></td>
        <td>2% to bronchial tree</td>
        <td style="width: 52px">
            <telerik:RadNumericTextBox ID="LignocaineBronchial2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox sumLignocaineClass" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox></td>
        <td>mls</td>
    </tr>
    <%--Added by rony tfs-4328--%>
    <tr>
        <td style="font-weight:bold;">Total</td>
        <td><telerik:RadNumericTextBox ID="LignocaineTotalTextBox" runat="server" Width="65" Skin="Windows7" ReadOnly="true" Font-Bold="true"></telerik:RadNumericTextBox></td>
        <td style="font-weight:bold;">mls</td>
    </tr>
</table>

<div class="control-sub-header" id="Div3" runat="server">Oxygen</div>
<table cellpadding="3" cellspacing="3" style="margin-top: 5px; padding: 15px;">
    <tr>
        <td>
            <asp:CheckBox ID="SupplyOxygenCheckBox" runat="server" Text="Supply oxygen mask" CssClass="broncho-drug-selection" />
        </td>
        <td>
            <telerik:RadNumericTextBox ID="SupplyOxygenPercentageTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
            &nbsp;%
        </td>
        <td style="width: 5px;"></td>
        <td align="right">Nasal cannulae
        </td>
        <td>
            <telerik:RadNumericTextBox ID="NasalTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
            &nbsp;L min<sup>-1</sup>
        </td>
    </tr>
    <tr>
        <td style="height: 10px;"></td>
    </tr>
    <tr>
        <td colspan="4">Saturation (SpO<sub>2</sub>)</td>
    </tr>
    <tr>
        <td>Pre-procedure baseline
        </td>
        <td>
            <telerik:RadNumericTextBox ID="SpO2BaseTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
            &nbsp;%
        </td>
        <td style="width: 5px;"></td>
        <td align="right">Minimum during procedure
        </td>
        <td>
            <telerik:RadNumericTextBox ID="SpO2MinTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" CssClass="broncho-drug-textbox" IncrementSettings-InterceptMouseWheel="false">
                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                <ClientEvents OnBlur="RemoveZero" OnValueChanging="RemoveZero" OnLoad="RemoveZero" OnValueChanged="saveBronchoDrugs" />
            </telerik:RadNumericTextBox>
            &nbsp;%
        </td>
    </tr>
</table>

<telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
    <script type="text/javascript">
        function RemoveZeros(sender, args) {
            var tbValue = sender._textBoxElement.value;
            if (tbValue.indexOf(".00") != -1)
                sender._textBoxElement.value = tbValue.substr(0, tbValue.indexOf(".00"));
        }

        function RemoveZero(sender, args) {
            RemoveZero(sender, args);
            saveBronchoDrugs();
        }

        function RemoveZero(sender, args) {
            var tbValue = sender._textBoxElement.value;
            if (tbValue == "0")
                sender._textBoxElement.value = "";

        }

        function openModifyDrugsPopUp() {
            var own = radopen("Options/ModifyPremedicationDrugs.aspx?option=0", "Premedication Drugs", '1000px', '700px');
            own.set_visibleStatusbar(false);
        }

        function openGuidelinesPopUp() {
            var own = radopen("Broncho/OtherData/GuidelinesForSedation.aspx", "Guidelines For Sedation", '1000px', '600px');
            own.set_visibleStatusbar(false);
        }
    </script>
</telerik:RadScriptBlock>

