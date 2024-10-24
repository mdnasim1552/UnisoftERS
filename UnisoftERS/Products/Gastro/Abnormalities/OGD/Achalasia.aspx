<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Achalasia.aspx.vb" Inherits="UnisoftERS.Achalasia" %>

<!DOCTYPE html>

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

        var achalasiaValueChanged = false;

        $(window).on('load', function () {
            TogglePerforationOptionBox();
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        $(document).ready(function () {
            $("#ContentDiv input:checkbox, input:radio").change(function () {
                achalasiaValueChanged = true;
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("ContentDiv");
                        $("#PerforationFieldset").hide();
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                        $("#PerforationFieldset").show();
                    }
                }
            });
            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (achalasiaValueChanged) {
                    localStorage.setItem('valueChanged', $("#AchalasiaProbableRadioButton").is(':checked') || $("#AchalasiaConfirmedRadioButton").is(':checked') || $("#NoneCheckBox").is(':checked') ? 'true' : 'false');
                    $("#SaveButton").click();
                }
            });
        });
       
         //changed by mostafiz issue 3647
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:radio:checked").prop('checked',false);
        }

        function TogglePerforationOptionBox() {
            if ($("#AchalasiaProbableRadioButton").is(':checked') || $("#AchalasiaConfirmedRadioButton").is(':checked')) {
                $("#PerforationFieldset").show();
            }
            else {
                $("#PerforationFieldset").hide();
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
        <telerik:RadScriptManager ID="AchalasiaRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="AchalasiaRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Achalasia</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="TherapeuticsTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 780px;">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th class="rgHeader" style="text-align: left;" colspan="2">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="AchalasiaProbableRadioButton" runat="server" Text="Probable" GroupName="DeformityRadioButtonList" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="AchalasiaConfirmedRadioButton" runat="server" Text="Confirmed" GroupName="DeformityRadioButtonList" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <div style="height: 15px;"></div>
                            <fieldset id="PerforationFieldset" runat="server" class="siteDetailsFieldset" style="display: block; width: 750px;">
                                <legend>Perforation</legend>
                                <table>
                                    <tr class="classHidePerforationTR">
                                        <td style="border: none;">Dilatation leading to perforation?
                                            <asp:RadioButtonList runat="server" ID="AchalasiaLeadingToPerforationRadioButton" CssClass="rbl rbl-confirmed"
                                                CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                <asp:ListItem Value="1">Yes</asp:ListItem>
                                                <asp:ListItem Value="0">No</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>

                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
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
