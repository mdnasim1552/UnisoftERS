<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_Deformity" Codebehind="Deformity.aspx.vb" %>

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

        .SiteDetailsButtonsPane {
            /*border-top-style: solid;
            border-top-width: 1px;
            border-top-color: ActiveBorder;*/
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            width: 790px !important;
        }
    </style>
    <script type="text/javascript">
        var deformityValueChanged = false;
        $(window).on('load', function () {
            ToggleOtherTextBox();
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        $(document).ready(function () {
            $("#ContentDiv input:checkbox, input:radio, input[type=text]").change(function () {
                deformityValueChanged = true;
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("ContentDiv");
                        $("#OtherTextBox").hide();
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                        ToggleOtherTextBox();
                    }
                }
            });
            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (deformityValueChanged) {
                    localStorage.setItem('valueChanged', $("#ContentDiv input:checkbox:checked").length > 0 || $("#ContentDiv input:radio:checked").length > 0  ? 'true' : 'false');
                    $("#SaveButton").click();
                } 
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });
         //changed by mostafiz issue 3647
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:radio:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
        }

        function ToggleOtherTextBox() {
            if ($("#OtherRadioButton").is(':checked')) {
                $("#OtherTextBox").show();
            }
            else {
                $("#OtherTextBox").hide();
                $("#OtherTextBox").val("");
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
        <telerik:RadScriptManager ID="DeformityRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DeformityRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Deformity</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TherapeuticsTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:780px;">
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2" >
                                                   <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="ExtrinsicCompRadioButton" runat="server" Text="Extrinsic compression" GroupName="DeformityRadioButtonList"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="CupAndSpillRadioButton" runat="server" Text="Cup and spill stomach" GroupName="DeformityRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="HourglassRadioButton" runat="server" Text="Hourglass stomach" GroupName="DeformityRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="PostOperativeRadioButton" runat="server" Text="Post operative stenosis" GroupName="DeformityRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="JShapedRadioButton" runat="server" Text="J-shaped stomach" GroupName="DeformityRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="SubMucosalRadioButton" runat="server" Text="Submucosal tumour" GroupName="DeformityRadioButtonList" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="OtherRadioButton" runat="server" Text="Other" GroupName="DeformityRadioButtonList" />
                                                    &nbsp;&nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="OtherTextBox" runat="server" Skin="Windows7" Width="250" />
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>


            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
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
