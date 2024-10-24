<%@ Page Title="" Language="vb" AutoEventWireup="true" MasterPageFile="~/Templates/Unisoft.master" Async="false" CodeBehind="AllTemporalTables.aspx.vb" Inherits="UnisoftERS.AllTemporalTables" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <style type="text/css">
        /*#ctl00_BodyContentPlaceHolder_EndDate_dateInput_Label{
            width:25% !important;
        }*/
        .AutoHeight {
            height: calc(100vh - 120px) !important;
        }
    </style>
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">
            $(document).ready(function () {

            });
            function exportToExcel(sender, args) {
                var masterTable = $find('<%= RadGrid1.ClientID %>').get_masterTableView();
                masterTable.exportToExcel();
            }
        </script>
    </telerik:RadCodeBlock>
</asp:Content>
<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">
    <div class="treeListBorder" style="margin-top: -5px;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" Skin="Default" BackColor="#f2f9fc" Width="280px" CssClass="OptionsBackgroundPane AutoHeight" />
    </div>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div style="margin-bottom: 5px; margin-top: 5px; padding-left: 0px; padding-right: 15px; width: 98%;">

                <telerik:RadLabel runat="server" ID="RadLabel1" AssociatedControlID="StartDate" Text="From: "></telerik:RadLabel>
                <telerik:RadDatePicker Skin="Windows7" ID="StartDate" Width="150px" runat="server" ShowPopupOnFocus="true" RenderMode="classic" />

                <telerik:RadLabel runat="server" ID="RadLabel2" AssociatedControlID="EndDate" Text="To: "></telerik:RadLabel>
                <telerik:RadDatePicker Skin="Windows7" ID="EndDate" Width="150px" runat="server" ShowPopupOnFocus="true" RenderMode="classic" />

                <telerik:RadButton Style="margin-left: 50px;" ID="SearchButton" runat="server" Text="Search" Width="90px" OnClick="SearchButton_Click"></telerik:RadButton>

                <telerik:RadButton Visible="false" Style="float: right !important;" ID="ExportToExcelButton" runat="server" Text="Export" OnClick="ExportToExcelButton_Click" Skin="Metro">
                    <Icon PrimaryIconUrl="~/Images/icons/excel.png" />
                </telerik:RadButton>

                <telerik:RadButton runat="server" ID="RadButton3" Text="Export To Excel" AutoPostBack="false" OnClientClicked="exportToExcel" Visible="false" />
            </div>
            <div id="Rdcontent" runat="server" visible="false" style="padding-left: 0px;">
                <telerik:RadGrid ID="RadGrid1" runat="server" AllowSorting="true" Style="padding-left: 0px; padding-right: 15px; width: 97%; height: 550px;"
                    Skin="Metro" PageSize="25" AllowPaging="true" AllowPageSizeSelection="True" RenderMode="Lightweight" AutoGenerateColumns="false"
                    OnPageIndexChanged="RadGrid1_PageIndexChanged" OnPageSizeChanged="RadGrid1_PageSizeChanged">
                    <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                    <CommandItemStyle BackColor="WhiteSmoke" />
                    <%-- <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="false"></ExportSettings>--%>
                    <MasterTableView CssClass="MasterClass" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AutoGenerateColumns="false" CommandItemDisplay="Top">
                        <CommandItemSettings ShowExportToExcelButton="false" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                    </MasterTableView>
                    <PagerStyle Mode="NextPrevAndNumeric" EnableAllOptionInPagerComboBox="true"
                        AlwaysVisible="true" BackColor="#f9f9f9" />
                    <ClientSettings EnableRowHoverStyle="true">
                        <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
                        <Selecting AllowRowSelect="true" />
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>
                    <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
                </telerik:RadGrid>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="ExportToExcelButton" />
        </Triggers>
    </asp:UpdatePanel>

</asp:Content>
