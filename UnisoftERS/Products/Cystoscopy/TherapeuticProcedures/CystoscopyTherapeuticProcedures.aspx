<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="CystoscopyTherapeuticProcedures.aspx.vb" Inherits="UnisoftERS.CystoscopyTherapeuticProcedures" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var cystoscopyTherapeuticProceduresChanged = false;
            $(window).on('load', function () {
                  $('input[type="checkbox"]').each(function () {
                        toggleSecondColum($(this).closest('tr'), $(this).is(":checked"))
                   });
            })
            function CloseWindow() {
                window.parent.CloseWindow();
            }

            $(document).ready(function () {
                $("#CystoscopyTherapeuticFormView_NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(":checked"))
                    changeState();
                })
                $("#CystoscopyTherapeuticFormView_TherapeuticTable tr td:first-child input").change(function () {
                    if ($(this).is(":checked")) {
                         $("#CystoscopyTherapeuticFormView_NoneCheckBox").prop("checked", false);
                    }   
                })
                $("#CystoscopyTherapeuticFormView_DiathermyCheckBox").change(function () {
                    var checked = $(this).is(":checked");
                    clearTextBoxOfRow($(this).closest('tr'), checked)
                    toggleSecondColum($(this).closest('tr'), checked)
                    changeState();
                })
                $("#CystoscopyTherapeuticFormView_LaserCheckBox").change(function () {
                    var checked = $(this).is(":checked");
                    clearTextBoxOfRow($(this).closest('tr'), checked)
                    toggleSecondColum($(this).closest('tr'), checked)
                    changeState();
                })
                //Added by rony tfs-4342
                $("#CystoscopyTherapeuticFormView_InjectionTherapyCheckBox").change(function () {
                    var checked = $(this).is(":checked");
                    clearTextBoxOfRow($(this).closest('tr'), checked)
                    toggleSecondColum($(this).closest('tr'), checked)
                })
                $("#CystoscopyTherapeuticFormView_TherapeuticTable tr td:first-child input:text").change(function () {
                    changeState();
                });

                $(window).on('beforeunload', function () {
                    if (cystoscopyTherapeuticProceduresChanged) $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            })

            function changeState() {
                cystoscopyTherapeuticProceduresChanged = true;
                if (!$('#CystoscopyTherapeuticFormView_NoneCheckBox').is(':checked') &&
                    !$('#CystoscopyTherapeuticFormView_DiathermyCheckBox').is(':checked') &&
                    !$('#CystoscopyTherapeuticFormView_LaserCheckBox').is(':checked')) {
                    localStorage.setItem('valueChanged', 'false');
                } else {
                    localStorage.setItem('valueChanged', 'true');
                }
            }

            function clearTextBoxOfRow(closestTR, checked) {
                if (checked) {
                    $("#CystoscopyTherapeuticFormView_NoneCheckBox").attr("checked", false);
                }
                else {
                    $(closestTR).find("input:text").each(function () {
                        $('input:text[id=' + $(this).attr('id') + ']').val('')  
                        //Added by rony tfs-4342
                        var injectionTypeBoxes = document.getElementsByClassName("injection-type-comboBox");
                        for (var i = 0; i < injectionTypeBoxes.length; i++) {
                            var comboBox = $find(injectionTypeBoxes[i].id);
                            if (comboBox) {
                                comboBox.clearSelection();
                            }
                        }
                    })
                }
            }

            function toggleSecondColum(closestTR, checked) {
                if (checked) {
                    $(closestTR).find(".secondCol").show();
                }
                else {
                    $(closestTR).find(".secondCol").hide();
                }
            }

            function ToggleNoneCheckBox(checked) {    
                if (checked) {                    
                    $("#CystoscopyTherapeuticFormView_TherapeuticTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    })
                }
                else {
                    $("#CystoscopyTherapeuticFormView_TherapeuticTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox").trigger("change");
                    })
                }
            }

        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadFormDecorator ID="rfdNoneCheckBox" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadFormDecorator ID="rfdOtherText" runat="server" DecoratedControls="All" DecorationZoneID="ButtonsRadPane" Skin="Web20" />
        <telerik:RadScriptManager ID="CystoscopyTherapeuticRadScriptManager" runat="Server"></telerik:RadScriptManager>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Therapeutic</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Scrolling="None">
                <asp:ObjectDataSource ID="CystoscopyTherapeuticObjectDataSource" runat="server" TypeName="UnisoftERS.Therapeutics"
                    SelectMethod="GetCystoScopyTherapeuticData" UpdateMethod="SaveCystoscopyTherapeuticData" InsertMethod="SaveCystoscopyTherapeuticData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0"></asp:Parameter>
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="none" Type="Boolean" />
                        <asp:Parameter Name="Diathermy" Type="Boolean" />
                        <asp:Parameter Name="DiathermyWatts" Type="Int32" />
                        <asp:Parameter Name="DiathermyPulses" Type="Int32" />
                        <asp:Parameter Name="DiathermySecs" Type="Double" />
                        <asp:Parameter Name="DiathermyKJ" Type="Int32" />
                        <asp:Parameter Name="Laser" Type="Boolean" />
                        <asp:Parameter Name="LaserWatts" Type="Int32" />
                        <asp:Parameter Name="LaserPulses" Type="Int32" />
                        <asp:Parameter Name="LaserSecs" Type="Double" />
                        <asp:Parameter Name="LaserKJ" Type="Int32" />
                        <asp:Parameter Name="Injection" Type="Boolean" />
                        <asp:Parameter Name="InjectionType" DbType="Int32" />
                        <asp:Parameter Name="InjectionVolume" Type="Int32" />
                        <asp:Parameter Name="InjectionNumber" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:FormView ID="CystoscopyTherapeuticFormView" runat="server" DefaultMode="Edit" DataSourceID="CystoscopyTherapeuticObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>
                        <div id="ContentDiv">
                            <div id="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TherapeuticTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 798px;">

                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>

                                                            <td style="border: none">
                                                                <asp:CheckBox ID="DiathermyCheckBox" runat="server" Text="Diathermy" Checked='<%# Bind("Diathermy")%>' />
                                                            </td>
                                                            <td class="secondCol" style="border: none; text-align:right; padding-right:50px;">


                                                                <telerik:RadNumericTextBox ID="DiathermyWattsRadNumericTextBox" runat="server" DbValue='<%# Bind("DiathermyWatts")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Watts"></asp:Label>
                                                                <telerik:RadNumericTextBox ID="DiathermyPulsesRadNumericTextBox" runat="server" DbValue='<%# Bind("DiathermyPulses")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Pluses"></asp:Label>
                                                                <telerik:RadNumericTextBox ID="DiathermySecsRadNumericTextBox" runat="server" DbValue='<%# Bind("DiathermySecs")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Sec"></asp:Label>
                                                                <telerik:RadNumericTextBox ID="DiathermyKJRadNumeric" runat="server" DbValue='<%# Bind("DiathermyKJ")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="KJ"></asp:Label>



                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>

                                                            <td style="border: none">
                                                                <asp:CheckBox ID="LaserCheckBox" runat="server" Text="Laser" Checked='<%# Bind("Laser")%>' />
                                                            </td>
                                                            <td class="secondCol" style="border: none; text-align:right; padding-right:50px;">
                                                                <telerik:RadNumericTextBox ID="LaserWattsRadNumericTextBox" runat="server" DbValue='<%# Bind("LaserWatts")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Watts"></asp:Label>

                                                                <telerik:RadNumericTextBox ID="LaserPulsesRadNumericTextBox" runat="server" DbValue='<%# Bind("LaserPulses")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Pluses"></asp:Label>
                                                                <telerik:RadNumericTextBox ID="LaserSecsRadNumericTextBox" runat="server" DbValue='<%# Bind("LaserSecs")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="Sec"></asp:Label>
                                                                <telerik:RadNumericTextBox ID="LaserKJRadNumericTextBox" runat="server" DbValue='<%# Bind("LaserKJ")%>'
                                                                    
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <asp:Label runat="server" Text="KJ"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <%--Added by rony tfs-4342--%>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>

                                                            <td style="border: none">
                                                                <asp:CheckBox ID="InjectionTherapyCheckBox" runat="server" Text="Injection therapy" Checked='<%# Bind("Injection")%>' />
                                                            </td>
                                                            <td class="secondCol" style="border: none; text-align:right; padding-right:50px;">
                                                                <telerik:RadComboBox ID="InjectionTypeComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="true" AutoPostBack="false" DataTextField="ListItemText" DataValueField="ListId" CssClass="injection-type-comboBox"/>
                                                                    &nbsp;&nbsp;&nbsp;total volume
                                                                    <telerik:RadNumericTextBox ID="InjectionVolumeNumericTextBox" runat="server" DbValue='<%# Bind("InjectionVolume")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    ml &nbsp;&nbsp;&nbsp;via
                                                                    <telerik:RadNumericTextBox ID="InjectionNumberNumericTextBox" runat="server" DbValue='<%# Bind("InjectionNumber")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    injections
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                              </tr>
                                        </tbody>
                                    </table>

                                </div>
                            </div>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </telerik:RadPane>
            <telerik:RadPane ID="RadPane2" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />

                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
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
<script type="text/javascript">           
    var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
    var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
</script>
    </form>
</body>
</html>
