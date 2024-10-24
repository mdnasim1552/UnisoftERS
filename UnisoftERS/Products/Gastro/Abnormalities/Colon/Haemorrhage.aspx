<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Haemorrhage" CodeBehind="Haemorrhage.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">
        var haemorrhageValueChanged = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });

        });

        $(document).ready(function () {
            //$("#DilatedCheckBox").change(function () {
            //    ToggleTRs($(this));
            //});

            //$("#StrictureCheckBox").change(function () {
            //    ToggleTRs($(this));
            //});

            $('input[type="checkbox"]').change(function () {
                ToggleTRs($(this));
                valueChanged();
            });

            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
            });
            $(window).on('beforeunload', function () {
                if (haemorrhageValueChanged) $('#SaveButton').click();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            haemorrhageValueChanged = true;
            var valueToSave = false;
            $("#CalibreTable tr td:first-child").each(function () {
                if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
            });
            if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');

        }

        //changed by mostafiz issue 3647
        function ToggleTRs(chkbox) {

            if (chkbox[0].id != "NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NoneCheckBox").prop('checked', false);  
                }
                chkbox.closest('td')
                    .nextUntil('tr').each(function () {
                        if (checked) {
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                            ClearControls($(this));
                        }
                    });
                var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
                if (typeof subRows !== typeof undefined && subRows == "1") {
                    chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                        if (checked) {
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                            ClearControls($(this));
                        }
                    });
                }
            }
        }
        //changed by mostafiz issue 3647
        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#CalibreTable tr td:first-child").each(function () {
                    $('input[type="checkbox"]').not('#NoneCheckBox').prop('checked', false);
                    //$('input[type="checkbox"]').not('#NoneCheckBox').trigger('change');
                });
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }
    </script>
</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }

        </script>
    </telerik:RadScriptBlock>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="CalibreRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Haemorrhage</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server">
                <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                    <div id="ContentDiv">
                        <div class="siteDetailsContentDiv">
                            <div class="rgview" id="rgAbnormalities" runat="server">
                                <table id="CalibreTable" runat="server" cellpadding="3" cellspacing="3" style="width: 780px; height: 245px;">
                                    <thead>
                                        <tr>
                                            <th class="rgHeader" style="text-align: left;">
                                                <asp:CheckBox ID="NoneCheckBox" runat="server" Text="&lt;b&gt;None&lt;/b&gt;" ForeColor="Black" Font-Bold="True" />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="ArtificialCheckBox" runat="server" Text="Artifactual bleeding" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>


                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="LesionsCheckBox" runat="server" Text="Bleeding from lesions" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="MelaenaCheckBox" runat="server" Text="Melaena from ileocaecal valve" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="MucosalCheckBox" runat="server" Text="Mucosal bleeding" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="PurpuraCheckBox" runat="server" Text="Purpura coli" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr>
                                                        <td style="border: none;">
                                                            <asp:CheckBox ID="TransportedCheckBox" runat="server" Text="Transported blood" />
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
                </telerik:RadAjaxPanel>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <div>
        </div>
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
