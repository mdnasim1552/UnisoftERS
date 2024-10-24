<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="CustomReporting.aspx.vb" Inherits="UnisoftERS.AuditReporting" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder2" runat="server">
    <style type="text/css">
        .table-row {
            margin-bottom: 10px;
        }

        /* #ctl00_ctl00_BodyContentPlaceHolder_BodyContentPlaceHolder_RadGrid1_GridHeader {
            margin-right: 0px !important;
        }*/

        .verticallyCenter {
            display: flex; /* Use Flexbox */
            align-items: center; /* Vertically align items */
            justify-content: center; /* Horizontally center items */
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <script type="text/javascript" src="../../Scripts/Reports.js"></script>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div id="loaderPreview">
                Loading...
            </div>
            <div id="ContentDiv">
                <table>
                    <tr>
                        <td>
                            <div class="optionsHeading">Reports</div>
                        </td>
                    </tr>

                </table>
                <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="95%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
                    <telerik:RadPane ID="ControlsRadPane" runat="server" Height="650px">
                        <asp:Panel ID="ReportPanel" runat="server" Style="margin:0px 10px 0px 10px">
                            <div style="width: 100%;">
                                <%-- <div style="margin-top: 10px;"></div>--%>
                                <div style="padding-bottom: 10px;height: 100%;min-height:95vh !important;" class="ConfigureBg">
                                    <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 10px; margin-left: 15px;" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td colspan="1" style="width: 38px;">Type:</td>
                                            <td colspan="2">
                                                <%--<telerik:RadLabel runat="server" ID="RadLabel1" AssociatedControlID="StartDate" Text="Report Type: "></telerik:RadLabel>--%>
                                                <telerik:RadComboBox ID="ERS_ReportingSectionsRadComboBox" AppendDataBoundItems="true" runat="server" AutoPostBack="true"
                                                    OnSelectedIndexChanged="ERS_ReportingSectionsRadComboBox_SelectedIndexChanged">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Text="Any" Value="0" Selected="true" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </td>
                                            <td colspan="1" style="width: 60px;">&nbsp;&nbsp;&nbsp;Report:</td>
                                            <td colspan="2">
                                                <telerik:RadComboBox ID="ERS_ReportingRadComboBox" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ERS_ReportingRadComboBox_SelectedIndexChanged">
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="display: flex; flex-direction: column; width: 439px;" runat="server" id="reportDiv" visible="false">
                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px; margin-left: 15px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span runat="server" id="reportNameId" style="padding-left: 5px;">User and Patients Audit</span>
                                                </div>
                                                <div class="content" style="padding: 7px;">
                                                    <table id="Table1" runat="server" class="optionsBodyText" style="margin-top: 10px; margin-left: 15px;" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td colspan="3">
                                                                <telerik:RadLabel style="margin-bottom:8px;" runat="server" ID="RadLabel1" AssociatedControlID="StartDate" Text="From: "></telerik:RadLabel>
                                                            </td>
                                                            <td colspan="4">
                                                                <telerik:RadDatePicker style="margin-bottom:5px;" Skin="Windows7" ID="StartDate" Width="150px" runat="server" ShowPopupOnFocus="true" RenderMode="classic" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3">
                                                                <telerik:RadLabel style="margin-bottom:8px;" runat="server" ID="RadLabel2" AssociatedControlID="EndDate" Text="To: "></telerik:RadLabel>
                                                            </td>
                                                            <td colspan="4">
                                                                <telerik:RadDatePicker style="margin-bottom:5px;" Skin="Windows7" ID="EndDate" Width="150px" runat="server" ShowPopupOnFocus="true" RenderMode="classic" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3">
                                                                <asp:PlaceHolder ID="dynamicLabel" runat="server"></asp:PlaceHolder>
                                                            </td>
                                                            <td colspan="4">
                                                                <asp:PlaceHolder ID="dynamicInputbox" runat="server"></asp:PlaceHolder>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3"></td>
                                                            <td colspan="4" style="display: flex; justify-content: flex-end;">
                                                                <telerik:RadButton ID="searchButton" runat="server" Text="Search" OnClick="searchButton_Click"></telerik:RadButton>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <%--<div style="display: flex; justify-content: flex-end;" runat="server" id="searchDiv" visible="false">
                                                        
                                                    </div>--%>
                                                </div>
                                            </div>
                                        </div>
                                    </div>



                                    <div style="margin-bottom: 5px; margin-top: 5px; padding-left: 0px; padding-right: 15px; width: 98%;">

                                        <telerik:RadButton Visible="false" Style="float: right !important; margin-top: 5px;" ID="ExportToExcelButton" runat="server" Text="Export" OnClick="ExportToExcelButton_Click" Skin="Metro">
                                            <Icon PrimaryIconUrl="~/Images/icons/excel.png" />
                                        </telerik:RadButton>
                                    </div>
                                    <div id="Rdcontent" runat="server" visible="false" style="padding-left: 0px; width: 100%;">
                                        <telerik:RadGrid ID="RadGrid1" runat="server" AllowSorting="true" Style="padding-left: 0px; padding-right: 15px; width: 97%; margin-bottom: 20px; margin-left: 15px;"
                                            Skin="Metro" PageSize="25" AllowPaging="true" AllowPageSizeSelection="True" RenderMode="Lightweight" AutoGenerateColumns="false"
                                            OnPageIndexChanged="RadGrid1_PageIndexChanged" OnPageSizeChanged="RadGrid1_PageSizeChanged">
                                            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                                            <CommandItemStyle BackColor="WhiteSmoke" />
                                            <%-- <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="false"></ExportSettings>--%>
                                            <MasterTableView CssClass="MasterClass" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AutoGenerateColumns="false" CommandItemDisplay="Top" Width="100%">
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

                                </div>
                            </div>
                        </asp:Panel>
                    </telerik:RadPane>
                </telerik:RadSplitter>
            </div>
            <telerik:RadScriptBlock runat="server">
                <script type="text/javascript" src="../../Scripts/Reports.js"></script>
                <script type="text/javascript">
                    $(document).ready(function () {
                        $("#loaderPreview").hide().delay(1000);
                        $(".collapsible_header").click(function () {

                            $header = $(this);
                            //getting the next element
                            $content = $header.next();
                            //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
                            $content.slideToggle(500, function () {
                                var $arrowSpan = $header.find('img');
                                if ($content.is(":visible")) {
                                    $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-down.png");
                                } else {
                                    $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-up.png");
                                }
                            });
                        });
                    });

                </script>
            </telerik:RadScriptBlock>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="ExportToExcelButton" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
