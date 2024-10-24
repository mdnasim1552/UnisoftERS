<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_OtherData_Coding" CodeBehind="Coding.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <style type="text/css">
      
       
    </style>
    <script type="text/javascript">
        $(window).on('load', function () {
            $.each(["DiagnosisDiv", "TherapeuticDiv", "EbusLymphNodeDiv"], function (index, value) {
                markTab(index, value, "<%= RadTabStrip1.ClientID%>");
            });
        });

        $(document).ready(function () {
            $.each(["DiagnosisDiv", "TherapeuticDiv", "EbusLymphNodeDiv"], function (index, value) {
                triggerChange(index, value, "<%= RadTabStrip1.ClientID%>");
            });
        });
    </script>
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />

    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div id="ContentDiv">
                    <div class="otherDataHeading">
                        <b>Coding</b>
                    </div>
                    <div style="margin-left: 20px;">
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="WebBlue"
                            Orientation="HorizontalTop">
                            <Tabs>
                                <telerik:RadTab Text="Diagnosis" Font-Bold="true" Value="0" />
                                <telerik:RadTab Text="Therapeutic" Font-Bold="true" Value="1" />
                                <telerik:RadTab Text="EBUS Lymph Node" Font-Bold="true" Value="2" />
                            </Tabs>
                        </telerik:RadTabStrip>

                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="DiagnosisDiv" class="multiPageDivTab">
                                    <fieldset id="DiagnosisFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Diagnostic endoscopic examination of the lower respiratory tract</legend>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:Repeater ID="DiagnosisRepeater" runat="server">
                                                        <HeaderTemplate>
                                                            <table cellpadding="3" cellspacing="3"> 
                                                                <tr>
                                                                    <td></td>
                                                                    <td>Fibre optic</td>
                                                                    <td>Rigid</td>
                                                                </tr>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td width="250px">
                                                                    <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                                                                    <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                                                                </td>
                                                                <td width="200px">
                                                                    <asp:CheckBox ID="FibreOpticCheckBox" runat="server" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>'/></td>
                                                                </td>
                                                                <td width="200px">
                                                                    <asp:CheckBox ID="RigidCheckBox" runat="server" Text='<%# Bind("RigidCode") %>' Checked='<%# Bind("RigidCodeValue") %>' /></td>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            </table>
                                                        </FooterTemplate>
                                                    </asp:Repeater>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="RadPageView2" runat="server">
                                <div id="TherapeuticDiv" class="multiPageDivTab">
                                    <fieldset id="TherapeuticFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Therapeutic endoscopic operations on lower respiratory tract</legend>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:Repeater ID="TherapeuticRepeater" runat="server">
                                                        <HeaderTemplate>
                                                            <table cellpadding="3" cellspacing="3">
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td width="250px">
                                                                    <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                                                                    <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                                                                </td>
                                                                <td width="200px">
                                                                    <asp:CheckBox ID="FibreOpticCheckBox" runat="server" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>'/></td>
                                                                </td>
                                                                <td width="200px">
                                                                    <asp:CheckBox ID="RigidCheckBox" runat="server" Text='<%# Bind("RigidCode") %>' Checked='<%# Bind("RigidCodeValue") %>' /></td>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            </table>
                                                        </FooterTemplate>
                                                    </asp:Repeater>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div id="EbusLymphNodeDiv" class="multiPageDivTab">
                                    <fieldset id="EbusFieldset" runat="server" class="otherDataFieldset">
                                        <legend>EBUS lymph node</legend>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:Repeater ID="EbusRepeater" runat="server">
                                                        <HeaderTemplate>
                                                            <table cellpadding="3" cellspacing="3">
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td width="300px">
                                                                    <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                                                                    <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                                                                </td>
                                                                <td width="200px">
                                                                    <asp:CheckBox ID="FibreOpticCheckBox" runat="server" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>'/></td>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            </table>
                                                        </FooterTemplate>
                                                    </asp:Repeater>
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
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="330px">
            <div style="height: 100px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">

            
        </script>
    </telerik:RadScriptBlock>
</asp:Content>
