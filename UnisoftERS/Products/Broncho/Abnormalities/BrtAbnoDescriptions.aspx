<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_Abnormalities_BrtAbnoDescriptions" Codebehind="BrtAbnoDescriptions.aspx.vb" %>

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
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });
            });

            $(document).ready(function () {
                $("#BRTAbnosTable tr td:first-child input:checkbox, input:radio").change(function () {
                    ToggleTRs($(this));
                });

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                });
            });

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "NoneCheckBox") {
                    $("#NoneCheckBox").attr('checked', false);
                }
            }

            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    $("#BRTAbnosTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#NoneCheckBox").prop("checked", true);
                }
            }


            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");
            }
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
        <div class="abnorHeader"><asp:Label ID="HeadingLabel" runat="server" Text="Abnormality Descriptions"></asp:Label></div>
        <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Width="95%">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="BRTAbnosTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:650px;">
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
                                    <tr id="CarinalTR" runat="server"> 
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; " class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="CarinalLabel" runat="server" Text="Carinal abnormality:"  />
                                                        </span> 
                                                        <asp:RadioButtonList ID="CarinalRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Normal"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Widened"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr id="VocalTR" runat="server" > <%--Vocal cord paralysis only applicable to 'right & left vestibular folds' and 'right & left vocal cords'--%>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="VocalLabel" runat="server" Text="Vocal cord paralysis:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="VocalRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Partial"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Complete"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr id="CompressionTR" runat="server">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; " class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD">
                                                        <div class="spanTitle" style="width:190px; padding-left:5px">
                                                            <asp:Label ID="CompressionLabel" runat="server" Text="Compression:" />
                                                        </div> 
                                                        <div>
                                                            <asp:CheckBox ID="CompressionGeneralCheckBox" runat="server" Text="General" width="250" />
                                                        </div>
                                                        <div style="float:left;">
                                                            <asp:CheckBox ID="CompressionFromLeftCheckBox" runat="server" Text="From left" />
                                                        </div>
                                                        <div style="float:left;">
                                                            <asp:CheckBox ID="CompressionFromRightCheckBox" runat="server" Text="From right" />
                                                        </div>
                                                        <br />
                                                        <div style="width:190px;">&nbsp;</div>
                                                        
                                                        <div style="float:left; padding-left:5px;">
                                                            <asp:CheckBox ID="CompressionFromAnteriorCheckBox" runat="server" Text="From anterior" />
                                                        </div>
                                                        <div style="float:left;">
                                                            <asp:CheckBox ID="CompressionFromPosteriorCheckBox" runat="server" Text="From posterior" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>


                                    <tr id="StenosisTR" runat="server" > 
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="StenosisLabel" runat="server" Text="Stenosis:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="StenosisRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Partial"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Complete"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>


                                    <tr id="ObstructionTR" runat="server" > 
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="ObstructionLabel" runat="server" Text="Obstruction:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="ObstructionRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Partial"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Complete"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr id="MucosalTR" runat="server">
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


                                    <tr id="MucosalIrregularityTR">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="MucosalIrregularityLabel" runat="server" Text="Mucosal irregularity:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="MucosalIrregularityRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Unknown"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Possible tumour"></asp:ListItem>
                                                            <asp:ListItem Value="3" Text="Definite tumour"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                            
                                    <tr id="SecretionsTR" runat="server">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="ExcessiveSecretionsLabel" runat="server" Text="Excessive secretions:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="ExcessiveSecretionsRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Purulent"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Non-purulent"></asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr id="BleedingTR" runat="server">
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%;" class="noborder">
                                                <tr>
                                                    <td class="mainAbnoTD" >
                                                        <span class="spanTitle">
                                                            <asp:Label ID="BleedingLabel" runat="server" Text="Bleeding:" />
                                                        </span> 
                                                        <asp:RadioButtonList ID="BleedingRBL" runat="server" CssClass="rbl"
                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                            <asp:ListItem Value="1" Text="Fresh"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Old"></asp:ListItem>
                                                        </asp:RadioButtonList>
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
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>

</html>
