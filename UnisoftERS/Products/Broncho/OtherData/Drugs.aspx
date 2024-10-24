<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_OtherData_Drugs" CodeBehind="Drugs.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <style type="text/css">
      
       .border_bottom {
            border-bottom: 1pt dashed #B8CBDE;
        }
    </style>

    <script type="text/javascript">
        $(window).on('load', function () {
            $.each(["SedationDiv", "AnaesthesiaDiv"], function (index, value) {
                markTab(index, value, "<%= RadTabStrip1.ClientID%>");
            });
            DrugsTab();
        });

        $(document).ready(function () {
            $.each(["SedationDiv", "AnaesthesiaDiv"], function (index, value) {
                triggerChange(index, value, "<%= RadTabStrip1.ClientID%>");
            });

              $("#multiPageDivTab").find("input[type=text],input:checkbox, select, textarea").change(function () {
                DrugsTab();
                ToggleNoneCheckBox($(this).attr("id"), $(this).val());
            });
        });

        function dosageChanged(sender, args) {
            var elemId = sender.get_element().id;
            var chkDosage = elemId.replace('txtDosage', 'PreMedChkBox');
            var v = sender.get_value();
            if (v > 0) {
                $(document.getElementById(chkDosage)).prop("checked", true);
            } else {
                $(document.getElementById(chkDosage)).prop("checked", false);
            }
        }

        function setDefaultValue(sender, args) {
            var elemId = sender.id;
            var hfDefDosage = elemId.replace('PreMedChkBox', 'hfDefDosage');
            var txtDosage = elemId.replace('PreMedChkBox', 'txtDosage');

            if (document.getElementById(elemId).checked) {
                if (document.getElementById(txtDosage) != null) {
                    document.getElementById(txtDosage).value = document.getElementById(hfDefDosage).value;
                }
            } else {
                if (document.getElementById(txtDosage) != null) {
                    document.getElementById(txtDosage).value = "";
                }
            }
        }
        function openPopUp() {
            var oWnd = $find("<%= ModifyDrugsListWindow.ClientID %>");
            oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Options/ModifyPremedicationDrugs.aspx?option=0")%>";
            oWnd.set_title("");
            oWnd.SetSize(1000, 700);
            
            //Add the name of the function to be executed when RadWindow is closed.
            oWnd.add_close(OnClientClose);
            oWnd.show();
          
            ////Add the name of the function to be executed when RadWindow is closed.
            //oWnd.add_close(OnClientClose);
            //oWnd.show();
            //var own = radopen("../Options/ModifyPremedicationDrugs.aspx?option=0", "Premedication Drugs", '1000px', '700px');
            //own.set_visibleStatusbar(false);
        }

        function OnClientClose(oWnd, eventArgs) {
            //Remove the OnClientClose function to avoid
            //adding it for a second time when the window is shown again.
       
            oWnd.remove_close(OnClientClose);

            __doPostBack('<%=ModifyDrugsListWindow.UniqueID %>', '');
        }

        function DrugsTab() {
            var apply = false;
            //$("#multiPageDivTab").find("input[type=text], select, textarea").each(function () {
            //    if ($(this).vasl() != null && $(this).val() != '') { apply = true; return false; }
            //});
            if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }
            setImage("0", apply);
        }

        function ToggleNoneCheckBox(id, value) {
            if (id == 'NoSedationChkBox') {// || id == 'GeneralAnaestheticChkBox') {
                $("#multiPageDivTab").find("input:checkbox:checked").not("[name*='" + id + "']").prop("checked", false);
                $("#multiPageDivTab").find("input:text").val('');
            } else {
                $('#NoSedationChkBox').prop("checked", false);
                //$('#GeneralAnaestheticChkBox').prop("checked", false);
            }
        }
   function setImage(ind, state) {
            var tabS = $find("<%= RadTabStrip1.ClientID%>");
            if (ind != undefined) {
                var tab = tabS.findTabByValue(ind);
                if (tab != null) {
                    if (state) {
                        //tab.set_imageUrl('../../Images/Ok.png');
                        tab.get_textElement().style.fontWeight = 'bold';

                    } else {

                        //tab.set_imageUrl('../../Images/none.png');
                        tab.get_textElement().style.fontWeight = 'normal';
                    }
                }
            }
        }
<%--        $(document).ready(function () {
            var prodId = getParameterByName('option');
            if (prodId == '0') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("0");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);

                } else if (prodId == '1') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("1");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);
                        }
                    });
        function refreshGrid(arg) {

            function getParameterByName(name) {
                name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
                var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                    results = regex.exec(location.search);
                return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
            }
            function ShowEditForm(id, rowIndex) {
                var grid = $find("<%= DrugsRadGrid.ClientID%>");

                var rowControl = grid.get_masterTableView().get_dataItems()[rowIndex].get_element();
                grid.get_masterTableView().selectItem(rowControl, true);
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugID=" + id + "&DrugType=" + type, "DrugListDialog", 630, 510);
                return false;
            }
            function ShowInsertForm() {
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugType=" + type, "DrugListDialog", 630, 510);
                return false;
            }
        }--%>

<%--                    $(document).ready(function () {
                var prodId = getParameterByName('option');
                if (prodId == '0') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("0");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);

                } else if (prodId == '1') {
                    //$("#<%= DrugTypeRadComboBox.ClientID%>").set_value("1");
                    $("#<%= DrugTypeRadComboBox.ClientID%>").prop("disabled", true);
                }
            });--%>
        <%--function refreshGrid(arg) {
            if (!arg) {
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }--%>
           <%-- function getParameterByName(name) {
                name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
                var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                    results = regex.exec(location.search);
                return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
            }
            function ShowEditForm(id, rowIndex) {
                var grid = $find("<%= DrugsRadGrid.ClientID%>");

                var rowControl = grid.get_masterTableView().get_dataItems()[rowIndex].get_element();
                grid.get_masterTableView().selectItem(rowControl, true);
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugID=" + id + "&DrugType=" + type, "DrugListDialog", 630, 510);
                return false;
            }
            function ShowInsertForm() {
                var box = $find("<%= DrugTypeRadComboBox.ClientID%>");
                var type = box.get_value();
                radopen("EditDrugs.aspx?DrugType=" + type, "DrugListDialog", 630, 510);
                return false;
            }--%>


</script>
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">

    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

<%--     <telerik:RadAjaxManagerProxy ID="RadAjaxManager1" runat="server">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="cmdSaveDefaults">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="SaveButton_Click">
                <UpdatedControls> 
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                    <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="cmdCancel">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="ModifyDrugsListWindow">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="MainPageRadSplitter" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManagerProxy>--%>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>

<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />

    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div id="ContentDiv">
                    <div class="otherDataHeading">
                        <b>Drugs</b>
                    </div>
                    <div style="margin-left: 20px;">
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="WebBlue"
                            Orientation="HorizontalTop">
                            <Tabs>
                                <telerik:RadTab Text="Sedation" Font-Bold="true" Value="0" />
                                <telerik:RadTab Text="Anaesthesia" Font-Bold="true" Value="1" />
                            </Tabs>
                        </telerik:RadTabStrip>

                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="multiPageDivTab" class="multiPageDivTab">
                                <%--    <fieldset id="SedationFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Drugs</legend>--%>
                                        <table>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td valign="top" style="padding-left: 7px;">
                                                                <table id="tableNoSedation" runat="server" cellspacing="3" cellpadding="0" border="0" />
                                                            </td>
                                                            <td valign="top" style="padding-left: 47px">
                                                                <table id="tableAnaesthetic" runat="server" cellspacing="3" cellpadding="0" border="0" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="border_bottom"></td>
                                                            <td class="border_bottom"></td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                <table id="tablePreMed1" runat="server" cellspacing="10" cellpadding="0" border="0" />
                                                            </td>
                                                            <td valign="top" style="padding-left: 40px">
                                                                <table id="tablePreMed2" runat="server" cellspacing="10" cellpadding="0" border="0" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="border_bottom"></td>
                                                            <td class="border_bottom"></td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top" style="padding-top: 10px">
                                                                <%--<telerik:RadButton ID="cmdModifyDrugs" runat="server" Text="Modify the list of drugs" OnClientClicked="openPopUp" Skin="Windows7" Icon-PrimaryIconCssClass="rbEdit" AutoPostBack="false" />--%>
                                                            </td>
                                                            <td valign="top" style="padding-top: 10px; padding-left: 47px">
                                                                <telerik:RadButton ID="cmdSaveDefaults" runat="server" Text="Save as my defaults" Skin="Windows7" Icon-PrimaryIconCssClass="telerikDefaultButton" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td width="20px"></td>
                                                <%--<td valign="bottom" align="right">
                                                    <telerik:RadButton ID="ModifyDrugsButton" runat="server" Text="Modify the list of drugs" OnClientClicked="openModifyDrugsPopUp" Skin="Windows7" Icon-PrimaryIconCssClass="rbEdit" AutoPostBack="false" />
                                                </td>--%>
                                            </tr>
                                        </table>
                                    <%--</fieldset>--%>

<%--                                    <fieldset id="EffectOfSedationFieldset" runat="server" class="otherDataFieldset" visible="false">
                                        <legend>Effect of sedation</legend>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:RadioButtonList ID="EffectOfSedationRadioButtonList" runat="server" CellSpacing="3" CellPadding="3">
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
                                        </table>
                                    </fieldset>--%>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div id="AnaesthesiaDiv" class="multiPageDivTab">
                                    <fieldset id="AnaesthesiaFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Local anaesthesia - Lidocaine / Lignocaine</legend>
                                        <table cellpadding="2" cellspacing="2" style="margin-top: 5px;">
                                            <tr>
                                                <td colspan="3">
                                                    <asp:CheckBox ID="LignocaineSprayCheckBox" runat="server" Text="spray" /></td>
                                                        <td colspan="2">
                                                            <telerik:RadNumericTextBox ID="LignocaineSprayTextBox" runat="server" Width="65" Skin="Windows7" MinValue="1" CssClass="broncho-drug-textbox">
                                                                <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                                <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                            </telerik:RadNumericTextBox>
                                                        </td>
                                                <td style="width: 20px;"></td>
                                                <td width="130px">1% to larynx via scope</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineViaScope1pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox>
                                                </td>
                                                <td>mls</td>
                                                <td style="width: 20px;"></td>
                                                <td width="110px">2% given trascicoid</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineTranscricoid2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox>
                                                </td>
                                                <td>mls</td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <asp:CheckBox ID="LignocaineGelCheckBox" runat="server" Text="gel" /></td>
                                                <td style="width: 20px;"></td>
                                                <td>2% to larynx via scope</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineViaScope2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                                <td style="width: 20px;"></td>
                                                <td>4% given trascicoid</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineTranscricoid4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                            </tr>
                                            <tr>
                                                <td width="100px">2% by nebuliser</td>
                                                <td>
                                                    <telerik:RadNumericTextBox ID="LignocaineNebuliser2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                                <td style="width: 20px;"></td>
                                                <td>4% to larynx via scope</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineViaScope4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                                <td style="width: 20px;"></td>
                                                <td>1% to bronchial tree</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineBronchial1pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                            </tr>
                                            <tr>
                                                <td>4% by nebuliser</td>
                                                <td>
                                                    <telerik:RadNumericTextBox ID="LignocaineNebuliser4pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                                <td style="width: 20px;"></td>
                                                <td></td>
                                                <td style="width: 52px"></td>
                                                <td></td>
                                                <td style="width: 20px;"></td>
                                                <td>2% to bronchial tree</td>
                                                <td style="width: 52px">
                                                    <telerik:RadNumericTextBox ID="LignocaineBronchial2pcTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox></td>
                                                <td>mls</td>
                                            </tr>
                                        </table>
                                    </fieldset>

                                    <fieldset id="OxygenFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Oxygen</legend>
                                        <table cellpadding="3" cellspacing="3" style="margin-top: 5px;">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="SupplyOxygenCheckBox" runat="server" Text="Supply oxygen mask" />
                                                </td>
                                                <td>
                                                    <telerik:RadNumericTextBox ID="SupplyOxygenPercentageTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox>
                                                    &nbsp;%
                                                </td>
                                                <td style="width: 5px;"></td>
                                                <td align="right">Nasal cannulae
                                                </td>
                                                <td>
                                                    <telerik:RadNumericTextBox ID="NasalTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
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
                                                    <telerik:RadNumericTextBox ID="SpO2BaseTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox>
                                                    &nbsp;%
                                                </td>
                                                <td style="width: 5px;"></td>
                                                <td align="right">Minimum during procedure
                                                </td>
                                                <td>
                                                    <telerik:RadNumericTextBox ID="SpO2MinTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                        <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                    </telerik:RadNumericTextBox>
                                                    &nbsp;%
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </div>
            </telerik:RadAjaxPanel>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>
    <telerik:RadWindowManager ID="PreMedWindowManager" runat="server"
        Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="ModifyDrugsListWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                Width="700px" Height="300px" Title="Modify Drugs" VisibleStatusbar="False" OnClientClose="closeWin"/>
        </Windows>
    </telerik:RadWindowManager>
    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">

            function RemoveZeros(sender, args) {
                var tbValue = sender._textBoxElement.value;
                if (tbValue.indexOf(".00") != -1)
                    sender._textBoxElement.value = tbValue.substr(0, tbValue.indexOf(".00"));
            }

            function RemoveZero(sender, args) {
                var tbValue = sender._textBoxElement.value;
                if (tbValue === "0")
                    sender._textBoxElement.value = "";
            }

            //function openModifyDrugsPopUp() {
            //    var own = radopen("../../Options/ModifyPremedicationDrugs.aspx?option=0", "Premedication Drugs", '1000px', '700px');
            //    own.set_visibleStatusbar(false);
            //}

            function openGuidelinesPopUp() {
                var own = radopen("GuidelinesForSedation.aspx", "Guidelines For Sedation", '1000px', '600px');
                own.set_visibleStatusbar(false);
            }

            function closeWin() {
                document.location.reload();
            }
        </script>
    </telerik:RadScriptBlock>
</asp:Content>
