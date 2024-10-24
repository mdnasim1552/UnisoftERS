<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_AtrophicDuodenum" Codebehind="AtrophicDuodenum.aspx.vb" %>

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
    <telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var atrophicDuodenumValueChanged = false;
        $(window).on('load', function () {
            if ($("#NoneCheckBox").is(':checked')) {
                ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), false);
            }
        });

        $(document).ready(function () {
            $("#FormDiv input:checkbox, input:radio").change(function () {
                if ($(this).is(':checked')) {
                    var elemId = $(this).attr("id");
                    if (elemId.indexOf("NoneCheckBox") > -1) {
                        ClearControls("FormDiv");
                    }
                    else {
                        $("#NoneCheckBox").prop('checked', false);
                    }
                }
                atrophicDuodenumValueChanged = true;
            });
            //Added by rony tfs-4166;
            $(window).on('beforeunload', function () {
                if (atrophicDuodenumValueChanged) {
                    $('#<%=SaveButton.ClientID%>').click(); 
                    valueChanged();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            var valueToSave = false;
            $("#FormDiv input:checkbox, input:radio").each(function () {
                if ($(this).is(':checkbox') && $(this).is(':checked')) {
                    valueToSave = true;
                }else if ($(this).is('input[type=radio]') && $(this).is(':checked')) {
                    valueToSave = true;
                }
            });
            if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }
        //changed by mostafiz issue 3647
        function ClearControls(parentCtrlId) {
            $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='NoneCheckBox']").removeAttr("checked");
            $("#" + parentCtrlId + " input:radio:checked").prop('checked', false);
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
        }

        function checkForValidPage() {
            //if ($("#NoneCheckBox").is(':checked'))   {  
            //    ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), false);
            //}else {
            //    ValidatorEnable(document.getElementById("TypeRequiredFieldValidator"), true);
            //}

            //var valid = Page_ClientValidate("Save");
            //if (!valid) {
            //    $find("SaveRadNotification").show();
            //}
        }
    </script>
    </telerik:RadScriptBlock> 
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
        <telerik:RadScriptManager ID="AtrophicDuodenumRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="AtrophicDuodenumRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Atrophic Duodenum</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                
                <div id="FormDiv" runat="server">
                    
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAtrophicDuodenum" runat="server" >
                            <table id="AtrophicDuodenumTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" width="770px" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div  style="margin:20px 10px;">
                        <fieldset id="GradingFieldset" runat="server" class="siteDetailsFieldset" style="display:block;width:750px;">
                            <legend>Type</legend>
                            <table>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList ID="TypeRadioButtonList" name="TypeRadioButtonList" runat="server"
                                            RepeatDirection="Vertical" RepeatLayout="Table">
                                            <asp:ListItem Value="1" Text="Mild"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Severe"></asp:ListItem>
                                        </asp:RadioButtonList>

                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
                <div>
                            <telerik:RadNotification ID="SaveRadNotification" runat="server" Animation="None"
                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                AutoCloseDelay="5000">
                                <ContentTemplate>
                                    <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true" DisplayMode="BulletList" 
                                        BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                </ContentTemplate>
                            </telerik:RadNotification>
                        </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;display:none;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="checkForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
