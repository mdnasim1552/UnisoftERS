<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="UpdateGMCCodes.aspx.vb" Inherits="UnisoftERS.UpdateGMCCodes" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Enter Missing GMC Codes</title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script src="../../Scripts/jquery-3.6.3.min.js"></script>

    <style type="text/css">
        .FormDiv {
            font-size: 12px;
        }

        .rgRow td {
            border-bottom: 1px solid #ededed !important;
        }

        .MasterClass {
            font: 0.9em 'Segoe UI', Arial, sans-serif !important;
        }

            .MasterClass .rgCaption {
                /*color: #026BB9;*/
                background-color: #f9f9f9;
                border-bottom: 1px solid #c2d2e2;
                font: 1.3em 'Segoe UI', Arial, sans-serif;
                text-align: left;
                color: #4888a2;
                padding: 3px 0px 3px 8px;
            }

        .rgHeaderDiv {
            margin-right: 0 !important;
            padding-right: 0px !important;
            background-color: #f9fafb !important;
        }

        div.RadGrid .rgRow,
        div.RadGrid .rgAltRow,
        div.RadGrid th.rgResizeCol,
        div.RadGrid .rgRow td,
        div.RadGrid .rgAltRow td,
        div.RadGrid .rgFilterRow td,
        div.RadGrid .rgEditRow td,
        div.RadGrid .rgFooter td {
            border-left-width: 1px !important;
            border-bottom-width: 0 !important;
            border-top-width: 0 !important;
        }

        div.RadGrid .rgHoveredRow {
            color: teal !important;
            background: #e8eef4 !important;
        }

        th.rgHeader {
            background-color: #ecf2f7 !important;
        }
        #MissingGMCCodesGrid_GridData{
            text-align: justify;
        }
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });

            function CloseAndSave(args) {
                GetRadWindow().BrowserWindow.updateGMC(args);
                GetRadWindow().close();
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" AutoCloseDelay="0" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="MissingGMCCodesGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="MissingGMCCodesGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="MissingGMCCodesGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SaveGMCCodeButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />

        <telerik:RadScriptManager runat="server" />
        <div style="text-align: center; padding-top: 10px;" id="FormDiv" runat="server" class="FormDiv">
            <telerik:RadNotification ID="UpdateGMCCodeRadNotifier" runat="server" Animation="Fade"
                EnableRoundedCorners="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                TitleIcon="delete" Position="Center" LoadContentOn="PageLoad"
                AutoCloseDelay="7000">
                <ContentTemplate>
                    <div id="updateGMCValDiv" runat="server" class="aspxValidationSummary"></div>
                </ContentTemplate>
            </telerik:RadNotification>

            <telerik:RadGrid ID="MissingGMCCodesGrid" runat="server" Skin="Metro" AutoGenerateColumns="false" RenderMode="Lightweight" AllowMultiRowSelection="false" Height="200px">
                <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="UserId" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                    <Columns>
                        <telerik:GridBoundColumn DataField="FullName" HeaderStyle-Width="175px" HeaderText="Endoscopist/Consultant" />
                        <telerik:GridTemplateColumn HeaderStyle-Width="100px" UniqueName="GMCCode" HeaderText="GMC Code">
                            <ItemTemplate>
                                <telerik:RadTextBox ID="GMCCodeTextBox" runat="server" Text='<%# Eval("ExistingGMCCode") %>' />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <NoRecordsTemplate>
                        No data.
                    </NoRecordsTemplate>
                </MasterTableView>
                <ClientSettings>
                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                </ClientSettings>
            </telerik:RadGrid>

            <div class="buttons" style="margin-top: 10px;">
                <telerik:RadButton ID="SaveGMCCodeButton" runat="server" Text="Save" OnClick="SaveGMCCodeButton_Click" />
                <telerik:RadButton ID="CancelSaveGMCCodeButton" runat="server" Text="Cancel" OnClientClicked="CloseWindow" />

            </div>
        </div>
    </form>
</body>
</html>
