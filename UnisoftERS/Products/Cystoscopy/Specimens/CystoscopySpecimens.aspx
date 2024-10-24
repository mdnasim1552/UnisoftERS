<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="CystoscopySpecimens.aspx.vb" Inherits="UnisoftERS.CystosocpySpecimensTaken" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var cystoscopySpecimensChange = false;
            function CloseWindow() {
                window.parent.CloseWindow();
            }

            $(document).ready(function () {
                ToggleForcepsReusable();
                $("#CystoscopySpecimensFormView_NoneCheckBox").change(function () {

                    ToggleNoneCheckBox($(this).is(":checked"))
                    setTimeout(function () {
                        changeState();
                    }, 10);
                })
                $("#CystoscopySpecimensFormView_QtyNumericTextBox, #CystoscopySpecimensFormView_QtyNumericTextBoxCytology").change(function () {

                    $("#CystoscopySpecimensFormView_NoneCheckBox").prop("checked", false);
                    setTimeout(function () {
                        changeState();
                    }, 10);
                });

                $(window).on('beforeunload', function () {
                    if (cystoscopySpecimensChange) {
                        $('#<%=SaveButton.ClientID%>').click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            })

            function changeState() {
                cystoscopySpecimensChange = true;
                if (!$('#CystoscopySpecimensFormView_NoneCheckBox').is(':checked') &&
                    ($('#CystoscopySpecimensFormView_QtyNumericTextBox').val() === '' || $('#CystoscopySpecimensFormView_QtyNumericTextBox').val() === 0) &&
                    ($('#CystoscopySpecimensFormView_QtyNumericTextBoxCytology').val() === '' || $('#CystoscopySpecimensFormView_QtyNumericTextBoxCytology').val() === 0)) {
                    localStorage.setItem('valueChanged', 'false');
                } else {
                    localStorage.setItem('valueChanged', 'true');
                }
            }

            function ToggleNoneCheckBox(checked) {

                if (checked) {
                    $("#CystoscopySpecimensFormView_SpecimensTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                        $(this).find("input:text").val("");
                    })
                }
            }

            function ToggleForcepsDisposable() {
                $("#CystoscopySpecimensFormView_ForcepsReusableCheckBox").removeAttr("checked");
                $("#CystoscopySpecimensFormView_ForcepsReusableCheckBox").trigger("change");
            }
            function ToggleForcepsReusable() {


                var selectedVal = $("#CystoscopySpecimensFormView_ForcepsReusableCheckBox").is(":checked");
                if (selectedVal) {
                    $("#CystoscopySpecimensFormView_ForcepsDisposableCheckBox").removeAttr("checked");
                    $("#CystoscopySpecimensFormView_SerialNoLabel").show();
                    $("#CystoscopySpecimensFormView_ForcepsReusableSerialNumberTextBox").show();
                }
                else {

                    $("#CystoscopySpecimensFormView_SerialNoLabel").hide();
                    $("#CystoscopySpecimensFormView_ForcepsReusableSerialNumberTextBox").hide();
                }
            }
        </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="CystoscopySpecimensRadScriptManager" runat="Server"></telerik:RadScriptManager>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Specimens Taken</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Scrolling="None">
                <asp:ObjectDataSource ID="CystoscopySpecimensObjectDataSource" runat="server" TypeName="UnisoftERS.SpecimensTaken"
                    SelectMethod="GetCystoscopySpecimensData" UpdateMethod="SaveCystoscopySpecimensData" InsertMethod="SaveCystoscopySpecimensData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0"></asp:Parameter>
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="none" Type="Boolean" />
                        <asp:Parameter Name="qunatity" Type="Int32" />
                        <asp:Parameter Name="qunatityCytology" Type="Int32" />
                        <asp:Parameter Name="forcepsDisposable" Type="Boolean" />
                        <asp:Parameter Name="forcepsReusable" Type="Boolean" />
                        <asp:Parameter Name="forcepsReusableSerialNumber" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:FormView ID="CystoscopySpecimensFormView" runat="server" DefaultMode="Edit" DataSourceID="CystoscopySpecimensObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>
                        <div id="ContentDiv">
                            <div id="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="SpecimensTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 798px;">

                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border:none;">Qty 
                                                                <telerik:RadNumericTextBox ID="QtyNumericTextBox" runat="server" DbValue='<%# Bind("Qunatity")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                to Histology
                                                            </td>
                                                        </tr>
                                                        
                                                        <tr>
                                                            <td style="border:none;">Qty 
                                                                <telerik:RadNumericTextBox ID="QtyNumericTextBoxCytology" runat="server" DbValue='<%# Bind("QunatityCytology")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                to Cytology
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr style="display:none;">
                                                <td>Forceps
                                                    <asp:CheckBox ID="ForcepsDisposableCheckBox" runat="server" Text="disposable" Checked='<%# Bind("ForcepsDisposable")%>' onchange="ToggleForcepsDisposable()" />
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="ForcepsReusableCheckBox" runat="server" Text="reusable" Checked='<%# Bind("ForcepsReusable")%>' onchange="ToggleForcepsReusable()" />

                                                    <asp:Label ID="SerialNoLabel" runat="server" Style="padding-left: 30px;">Serial Number:</asp:Label>
                                                    <telerik:RadTextBox ID="ForcepsReusableSerialNumberTextBox" runat="server" Text='<%# Bind("ForcepsReusableSerialNumber") %>' style></telerik:RadTextBox>

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
    </form>
</body>
</html>
