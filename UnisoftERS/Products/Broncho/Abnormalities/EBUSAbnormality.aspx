<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EBUSAbnormality.aspx.vb" Inherits="UnisoftERS.EBUSAbnormality" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            $(window).on('load', function () {

            });

            $(document).ready(function () {

            });

            function CloseWindow() {
                setRehideSummary();
                window.parent.CloseWindow();
            }
            function OnCloseEBUSAbnormalityDescriptionsRadWindow() {
                window.location.href = window.location.href;
                //window.location.href = window.location.href;
            }
        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        #RAD_SPLITTER_PANE_CONTENT_RadPane1 {
            height: calc(85vh - 25px) !important;
            overflow: auto;
        }
    </style>
</head>
<body>
    <form id="form2" runat="server">
        <telerik:RadScriptManager ID="EBUSAbnosRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="EBUSAbnosRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="abnorHeader">
                    <asp:Label ID="HeadingLabel" runat="server" Text="EBUS abnormality descriptions"></asp:Label>
                </div>
                <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                    <telerik:RadPane ID="RadPane1" runat="server">
                        <div id="FormDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">

                                    <table id="LesionsTable" class="rgview" style="table-layout: fixed; min-width: 100% !important;" cellpadding="0" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="1">
                                                    <telerik:RadButton ID="EnterDetailsRadButton" runat="server" Text="Add Description" Skin="Windows7" CssClass="EBUSAbnoDesc-btn" OnClick="EnterDetailsRadButton_Click" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>


                                            <tr id="EbusAbnormalityDescription" runat="server">
                                                <td style="padding: 0px; height: 40px; vertical-align: top;" colspan="1">
                                                    <div>
                                                        <asp:Repeater ID="EbusAbnormalityRepeater" runat="server" OnItemCommand="EbusAbnormalityRepeater_ItemCommand" OnItemDataBound="EbusAbnormalityRepeater_ItemDataBound">

                                                            <ItemTemplate>
                                                                <asp:HiddenField ID="EBUSAbnoDescIdHiddenValue" runat="server" Value='<%# Eval("EBUSAbnoDescId") %>' />
                                                                <table style="border-bottom: 1px solid #c2d2e2; padding: 3px; width: 100%; table-layout: fixed;" class="EBUSAbnoDesc-table">
                                                                    <tr>
                                                                        <%--<td class="rgCell" style="vertical-align: top;" colspan="1">--%>
                                                                        <td class="rgCell" style="vertical-align: central; width: 80px; display: none;">
                                                                            <span>Normal:&nbsp;</span><asp:CheckBox ID="NormalCheckBox" runat="server" Enabled="false" CssClass="abnormality-result" Checked='<%# Eval("Normal") %>' />
                                                                        </td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 30px !important;" rowspan="1"><strong>Sample:&nbsp;<asp:Label ID="lblEBSample" runat="server" Text='<%#Eval("EBSample") %>' /></strong></td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 80px !important;">(<strong>Size:&nbsp;<asp:Label ID="lblSize" runat="server" Text='<%#Eval("Size") %>' />mm</strong>)</td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 80px !important;">Size Number:&nbsp;<asp:Label ID="lblSizeNum" runat="server" Text='<%#Eval("SizeNum") %>' /></td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 80px !important;">Shape:&nbsp;<asp:Label ID="lblshape" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("Shape")), "None", If(CInt(Eval("Shape")) = 1, "Oval", If(CInt(Eval("Shape")) = 2, "Round", If(CInt(Eval("Shape")) = 3, "Triangular", "None")))) %>' /></td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 80px !important;">Margin:&nbsp;<asp:Label ID="Label1" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("Margin")), "None", If(CInt(Eval("Margin")) = 1, "Indistinct", If(CInt(Eval("Margin")) = 2, "Distinct", "None"))) %>' /></td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 20px !important;" rowspan="1">
                                                                            <asp:LinkButton ID="RemoveEntryLinkButton" runat="server" Text="Remove" CommandArgument='<%# Eval("EBUSAbnoDescId") %>' CommandName="remove" />
                                                                        </td>
                                                                        <td class="rgCell" style="vertical-align: central; width: 20px !important;" rowspan="1">
                                                                            <asp:LinkButton ID="EditlinkButton" runat="server" Text="Edit" CommandArgument='<%# Eval("EBUSAbnoDescId") %>' CommandName="Edit" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="vertical-align: central; " colspan="5">
                                                                            <span>Echogenecity:&nbsp;<asp:Label ID="Label2" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("Echogenecity")), "None", If(CInt(Eval("Echogenecity")) = 1, "Homogeneous", If(CInt(Eval("Echogenecity")) = 2, "Heterogeneous", "None"))) %>' />,</span>
                                                                            <span>Central hilar structure:&nbsp;<asp:Label ID="Label3" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("CHS")), "None", If(CInt(Eval("CHS")) = 1, "Present", If(CInt(Eval("CHS")) = 2, "Absent", "None"))) %>' />,</span>
                                                                            <span>Coagulation necrosis sign:&nbsp;<asp:Label ID="Label4" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("CNS")), "None", If(CInt(Eval("CNS")) = 1, "Present", If(CInt(Eval("CNS")) = 2, "Absent", "None"))) %>' />,</span>
                                                                            <span>Vascular:&nbsp;<asp:Label ID="Label5" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("Vascular")), "None", If(CInt(Eval("Vascular")) = 1, "Yes", If(CInt(Eval("Vascular")) = 2, "No", "None"))) %>' />,</span>
                                                                            <span>Biopsy type:&nbsp;<asp:Label ID="Label6" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("BxType")), "None", If(CInt(Eval("BxType")) = 1, "FNA", If(CInt(Eval("BxType")) = 2, "Core Bx", "None"))) %>' />,</span>
                                                                            <span>Biopsy Number taken:&nbsp;<asp:Label ID="Label7" runat="server" Text='<%#Eval("NoBxTaken") %>' />,</span>
                                                                            <span>Needle type:&nbsp;<asp:Label ID="Label8" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("BxNeedleType")), "None", If(CInt(Eval("BxNeedleType")) = 1, "Transbronchial", If(CInt(Eval("BxNeedleType")) = 2, "Aspiration", "None"))) %>' />,</span>
                                                                            <span>Diam:&nbsp;<asp:Label ID="Label9" runat="server" Text='<%#Eval("BxNeedleSize") %>' />,</span>
                                                                            <span>Needle Size Unit:&nbsp;<asp:Label ID="Label10" runat="server" Text='<%# If(String.IsNullOrEmpty(Eval("BxNeedleSizeUnits")), "None", If(CInt(Eval("BxNeedleSizeUnits")) = 1, "Ga (gauge)", If(CInt(Eval("BxNeedleSizeUnits")) = 2, "mm (millimetres)", "None"))) %>' /></span>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                            <FooterTemplate>
                                                            </FooterTemplate>
                                                        </asp:Repeater>
                                                    </div>
                                                </td>

                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </telerik:RadPane>
                    <telerik:RadPane ID="RadPane2" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane" Visible="false">
                        <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                        </div>
                    </telerik:RadPane>
                </telerik:RadSplitter>


                <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false" OnClientClose="OnCloseEBUSAbnormalityDescriptionsRadWindow">
                    <Windows>
                        <telerik:RadWindow ID="EBUSAbnormalityDescriptionsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="EBUS abnormality descriptions" VisibleStatusbar="false" Modal="True" Skin="Metro">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>
            </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
