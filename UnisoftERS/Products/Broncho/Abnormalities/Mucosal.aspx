<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Mucosal.aspx.vb" Inherits="UnisoftERS.Mucosal" %>

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
            var mucosalValueChanged = false;
               function refreshParentEBUS(siteid) {

                var test = parent.location.href;
                test = test.replace("SiteId=-1", "SiteId=" + siteid);

                parent.location.href = test + '&DefaultNav=yes'
                // console.log(parent.location.href);

                //parent.location.reload();
            }

            $(window).on('load', function () {
                //$('input[type="checkbox"]').each(function () {
                //    ToggleTRs($(this));
                //});
            });

            $(document).ready(function () {
                $("#BRTAbnosTable tr td:first-child input:checkbox, input:radio").change(function () {
                    ToggleTRs($(this));
                    mucosalValueChanged = true;
                });

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                    mucosalValueChanged = true;
                });
                //Added by rony tfs-4166
                $(window).on('beforeunload', function () {
                    if (mucosalValueChanged) {
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
                $("#BRTAbnosTable tr td:first-child input:checkbox").each(function () {
                    if ($(this).is(':checkbox') && $(this).is(':checked')) {
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
            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "NoneCheckBox") {
                    $("#NoneCheckBox").prop('checked', false);
                }
            }
            //changed by mostafiz issue 3647
            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    $("#BRTAbnosTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#NoneCheckBox").prop("checked", true);
                }
            }


            //function ClearControls(tableCell) {
            //    tableCell.find("input:radio:checked").removeAttr("checked");
            //    tableCell.find("input:checkbox:checked").removeAttr("checked");
            //    tableCell.find("input:text").val("");
            //}
        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        .rbl label
        {   display: inline-block; 
            width: 90px; 
            padding-right:10px;
        }


        .mainAbnoTD {
            border: 0px none ;
            border-style: none;
            border-width: 0;
            width: 180px;
        }
        .spanTitle {
            display: inline-block;
            width:190px;
            color:black;
        }
        .noborder, .noborder tr, .noborder th, .noborder td { border: none; }
        .noborder div { float:left;width:120px; }
    </style>
</head>
<body>
    <form id="form2" runat="server">
        <telerik:RadScriptManager ID="BRTAbnosRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="BRTAbnosRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader"><asp:Label ID="HeadingLabel" runat="server" Text="Mucosal"></asp:Label></div>
        <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Width="95%">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="BRTAbnosTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:780px;">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th class="rgHeader" style="text-align: left;" >
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="Normal" ForeColor="Black" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr runat="server"> 
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; " class="noborder">
                                                <tr>
                                                   <td class="mainAbnoTD">
                                                        <div class="spanTitle" style="width:190px;">
                                                            <asp:Label ID="MucosalLabel" runat="server" Text="Mucosal:" />
                                                        </div>
                                                        <div style="padding-left:5px;">
                                                            <asp:CheckBox ID="MucosalOedemaCheckBox" runat="server" Text="Oedema"  />
                                                        </div>
                                                        <div>
                                                            <asp:CheckBox ID="MucosalErythemaCheckBox" runat="server" Text="Erythema" />
                                                        </div>
                                                        <div>
                                                            <asp:CheckBox ID="MucosalPitsCheckBox" runat="server" Text="Pits" />
                                                        </div>
                                                        <br />
                                                        <div style="width:190px;">&nbsp;</div>
                                                        
                                                        <div style="padding-left:5px;">
                                                            <asp:CheckBox ID="MucosalAnthracosisCheckBox" runat="server" Text="Anthracosis" />
                                                        </div>
                                                        <div>
                                                            <asp:CheckBox ID="MucosalInfiltrationCheckBox" runat="server" Text="Infiltration" />
                                                        </div>
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

            </telerik:RadPane>
            <telerik:RadPane ID="RadPane2" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;display:none;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>

</html>
