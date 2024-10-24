<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_EUS_Mediastinal" Codebehind="Mediastinal.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .RadSplitterNoBorders {
            border-style: none !important;
        }
    </style>
    <script type="text/javascript">
        var mediastinalChanged = false;
        $(window).on('load', function () {
            ToggleOtherTextBox();
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        $(document).ready(function () {
            $("#ContentDiv input:checkbox, input:radio").change(function () {
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("ContentDiv");
                        $("#StationTextBox").hide();
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                        ToggleOtherTextBox();
                    }
                }
                valueChanged();
            });
            $(window).on('beforeunload', function () {
                if (mediastinalChanged) $('#SaveButton').click();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            mediastinalChanged = true;
            var valueToSave = false;
            $("#ContentDiv input:checkbox, input:radio").each(function () {
                if ($(this).is(':checked')) valueToSave = true;
            });
            if (!valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:radio:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
        }

        function ToggleOtherTextBox() {
            if ($("#LymphNodeRadioButton").is(':checked')) {
                //$("#StationTextBox").show();
                $("#StationSpan").show();
            }
            else {
                $("#StationSpan").hide();
                //$("#StationTextBox").hide();
                $("#StationTextBox").val("");
            }
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
        <telerik:RadScriptManager ID="MediastinalRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="MediastinalRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader" runat="server" id="AbnoHeaderDiv">Mediastinal</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TherapeuticsTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:650px;">
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" >
                                                   <asp:CheckBox ID="NoneCheckBox" runat="server" Text="Normal" Style="margin-right: 10px;" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="MassRadioButton" runat="server" Text="Mass" GroupName="MediastinalRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="LymphNodeRadioButton" runat="server" Text="Lymph node" GroupName="MediastinalRadioButtonList" />
                                                    &nbsp;&nbsp;&nbsp;
                                                    <span runat="server" id="StationSpan" style="vertical-align:middle;">
                                                        (&nbsp;station &nbsp;
                                                        <telerik:RadTextBox ID="StationTextBox" runat="server" Width="50" Skin="Windows7" MaxLength="15" />
                                                        &nbsp;)
                                                    </span>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>


            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
