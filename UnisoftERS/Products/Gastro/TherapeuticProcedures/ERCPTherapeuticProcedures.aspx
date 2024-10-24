<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_TherapeuticProcedures_ERCPTherapeuticProcedures" CodeBehind="ERCPTherapeuticProcedures.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <%--<telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />--%>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

        .SiteDetailsForm td {
            padding-bottom: 10px;
        }

        .rblType label {
            margin-right: 20px;
        }

        .BandLigationTR_Option {
            float: left;
            width: 145px;
        }

        .decompressTheDuctOption {
            float: right;
            padding-left: 10px;
            border: 0;
            background-color: #eafae9;
            margin-right: 0;
            border: 1px solid #d6ebd5;
        }

        .correctPlacementAcrossStricture {
            padding: 5px 10px;
            border: 0;
            background-color: #eafae9;
            margin-right: 10px;
            border: 1px solid #d6ebd5;
            margin-top: 5px;
        }

        .rtsSelected, .rtsSelected span {
            color: red;
        }

        .ercpTherapeuticProceduresHeight{
            height: 86vh !important;
        }

        .ercpTherapeuticsTableHeight{
            height: calc(65vh - 20px) !important;
        }
    </style>

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
        <telerik:RadScriptManager ID="ERCPTherapeuticRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="rfdNoneCheckBox" runat="server" DecoratedControls="All" DecorationZoneID="TabStripContainer" Skin="Web20" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Therapeutic Procedures</div>
        <div id="TabStripContainer" class="siteDetailsContentDiv">
            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="680px" CssClass="ercpTherapeuticProceduresHeight" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                <!-- This is the Parent Container for the UCs Actual Height and Width settings here! -->
                <telerik:RadPane ID="radPaneNoneCheckBox" runat="server" Height="40px" Scrolling="None" Index="0">
                    <div id="divNoneCheckBox" class="shaded-tab-header" style="padding-left: 10px;">
                        <asp:CheckBox ID="chkNoneCheckBox" runat="server" Text="None" ForeColor="Black" TabIndex="0" />
                        <span style="float: right">
                            <asp:RadioButtonList runat="server" RepeatDirection="Horizontal" ID="ObservedAssistedOptions">
                                <asp:ListItem ID="optObserved" runat="server" Text="Observed" />
                                <asp:ListItem ID="optAssisted" runat="server" Text="Assisted" />
                                <asp:ListItem ID="optIndependent" runat="server" Text="Trainer Independent" />
                                <asp:ListItem ID="optTrainerCompleted" runat="server" Text="Trainer Completed" />
                                <asp:ListItem ID="optIndependentEndo2" runat="server" style="visibility: hidden" />
                            </asp:RadioButtonList>
                        </span>
                    </div>
                </telerik:RadPane>

                <telerik:RadPane ID="ControlsRadPane" runat="server" Width="680px" CssClass="ercpTherapeuticsTableHeight rgview">


                    <asp:HiddenField ID="hiddenTherapeuticId" runat="server" />
                    <asp:HiddenField ID="hiddenSiteId" runat="server" />

                    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
                    <asp:Panel ID="panERCPTherapeuticsFormView" runat="server">
                        <div id="ContentDiv" style="overflow: auto;">
                            <div class="">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TherapeuticsTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 640px; margin: 0;">
                                        <!-- in CSS [style] '%' value does NOT work when Telerik tyle is Added! -->
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead style="display: none">
                                        </thead>
                                        <tbody>
                                            <!-- A's -->
                                            <!--Argon Beam Diathermy : Conditional-> For DUODENUM Sites-->
                                            <tr id="ArgonBeamDiathermyTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="ArgonBeamDiathermyCheckBox" runat="server" Checked='<%# Bind("ArgonBeamDiathermy")%>' Text="Argon beam diathermy" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px;">
                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyWattsNumericTextBox" runat="server" DbValue='<%# Bind("ArgonBeamDiathermyWatts")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                W
                                                                &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyPulsesNumericTextBox" runat="server" DbValue='<%# Bind("ArgonBeamDiathermyPulses")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                pulses
                                                                &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermySecsNumericTextBox" runat="server" DbValue='<%# Bind("ArgonBeamDiathermySecs")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5" NumberFormat-AllowRounding="true"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                sec
                                                                 &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyKJNumericTextBox" runat="server" DbValue='<%# Bind("ArgonBeamDiathermyKJ")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                                kJ
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- B's -->
                                            <!--BandLigationTR: Conditional ==> For DUODENUM Site-->
                                            <tr id="BandLigationTR" runat="server" visible="false">
                                                <td style="padding: 6px 8px;">
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="BandLigationCheckBox" runat="server" Text="Band ligation" /></span>
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="BotoxInjectionCheckBox" runat="server" Text="Botox injection" /></span>
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="EndoloopPlacementCheckBox" runat="server" Text="Endoloop placement" /></span>
                                                    <span class="BandLigationTR_Option" style="width: 180px;">
                                                        <asp:CheckBox ID="HeatProbeCheckBox" runat="server" Text="Heater probe coagulation" /></span>
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="DiathermyCheckBox" runat="server" Text="Diathermy" /></span>
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="ForeignBodyCheckBox" runat="server" Text="Foreign body removal" /></span>
                                                    <span class="BandLigationTR_Option">
                                                        <asp:CheckBox ID="HotBiopsyCheckBox" runat="server" Text="Hot biopsy" /></span>
                                                </td>
                                            </tr>
                                            <tr id="BalloonDialationTR">
                                                <td style="padding: 0;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BalloonDilationCheckBox" runat="server" Text="Balloon sphincteroplasty" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;">Dilated to &nbsp;
                                                                <telerik:RadNumericTextBox ID="BalloonDilatedToNumber" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="BalloonDilatationUnitsComboBox" runat="server" Skin="Windows7" Width="50" MarkFirstMatch="true" />
                                                                <span style="padding-left: 10px; padding-right: 3px;">using</span>
                                                                <telerik:RadComboBox ID="BalloonDilatorTypeComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>


                                            <!-- BalloonTrawlTR. Conditional: For Billiary / Pancreas -->
                                            <tr id="BalloonTrawlTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BalloonTrawlCheckBox" runat="server" Text="Balloon trawl" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;">
                                                                <span style="padding-left: 3px; padding-right: 1px;">using</span>
                                                                <telerik:RadComboBox ID="BalloonTrawlDilatorTypeComboBox" runat="server" Skin="Windows7" Width="110" MarkFirstMatch="true" />
                                                                <span style="padding-left: 5px; padding-right: 1px;">Size</span>
                                                                <telerik:RadNumericTextBox ID="BalloonTrawlDilatorSizeTextBox" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="BalloonTrawlDilatorUnitsComboBox" runat="server" Skin="Windows7" Width="50" MarkFirstMatch="true" />

                                                                <div id="BalloonDecompressedDiv" class="decompressTheDuctOption" runat="server" visible="false">
                                                                    <%--In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed under "Balloon trawl" tr--%>
                                                                    <asp:Label runat="server" for="BalloonDecompressedRadioButton">Decompressed the duct</asp:Label>
                                                                    <asp:RadioButtonList ID="BalloonDecompressedRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                                &nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="BalloonTrawlSuccessfulCheckBox" runat="server" Text="Successful" Style="margin-right: 0;" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- BalloonDilatationTR. Conditional: For ? SEi2 addition-->
                                            <tr id="BalloonDilatationTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BalloonDilatationCheckBox" runat="server" Text="Balloon dilatation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- BougieDilatationTR. Conditional: For ? SEi2 addition-->
                                            <tr id="BougieDilatationTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BougieDilatationCheckBox" runat="server" Text="Bougie dilatation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- BougieDilationTR. Conditional: For ? SEi2 addition-->
                                            <tr id="BougieDilationTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BougieDilationCheckBox" runat="server" Text="Bougie dilation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- BrushCytologyTR. Conditional: For ? SEi2 addition-->
                                            <tr id="BrushCytologyTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BrushCytologyCheckBox" runat="server" Text="Brush cytology" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- C's -->
                                            <!-- Conditional: For BILIARY or PANCREAS Site-->
                                            <tr id="CannulationTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <div style="float: left; width: 180px;">
                                                                    <asp:CheckBox ID="CannulationCheckBox" runat="server" Text="Cannulation" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 180px;">
                                                                    <asp:CheckBox ID="DiagnosticCholangiogramCheckBox" runat="server" Text="Diagnostic cholangiogram" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 100px;">
                                                                    <asp:CheckBox ID="HaemostasisCheckBox" runat="server" Text="Haemostasis" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 150px;">
                                                                    <asp:CheckBox ID="NasopancreaticDrainCheckBox" runat="server" Text="Nasobiliary drain" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 180px;">
                                                                    <asp:CheckBox ID="RendezvousProcedureCheckBox" runat="server" Text="Combined procedure (Rendez-vous)" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 180px;">
                                                                    <asp:CheckBox ID="DiagnosticPancreatogramCheckBox" runat="server" Text="Diagnostic pancreatogram" Style="margin-right: 0;" />
                                                                </div>
                                                                <div style="float: left; width: 100px;">
                                                                    <asp:CheckBox ID="ManometryCheckBox" runat="server" Text="Manometry" Style="margin-right: 0;" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Conditional: For Duodenum Site-->
                                            <tr id="ClipTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="ClipCheckBox" runat="server" Text="Clip" />
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;No of clips
                                                                <telerik:RadNumericTextBox ID="ClipRadNumericTextBox" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadTextBox ID="ClipTextBox" runat="server" Width="100px" Visible="false" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- CholangioscopyTR Condtional: For ? SEi2 addition -->
                                            <tr id="CholangioscopyTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CholangioscopyCheckBox" runat="server" Text="Cholangioscopy" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px;">
                                                            <td style="border: none; text-align: left; padding-left: 2px; vertical-align: top;">
                                                                <div class="divChildControl" style="float: left;">
                                                                    <asp:RadioButtonList ID="CholangioscopyRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="lesion assessment"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="visually directed stone therapy"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- D's -->
                                            <tr id="DiverticulotomyTR" runat="server" visible="false">
                                                <td style="padding: 0px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="DiverticulotomyCheckBox" runat="server" Checked='<%# Bind("Diverticulotomy")%>' Text="Diverticulotomy" TabIndex="60" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- E's -->
                                            <!-- Endoscopic cyst puncture. Conditional: For BILIARY or PANCREAS Site-->
                                            <tr id="EndoscopicCystPunctureTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px; vertical-align: top;">
                                                                <asp:CheckBox ID="EndoscopicCystPunctureCheckBox" runat="server" Checked='<%# Bind("EndoscopicCystPuncture")%>' Text="Endoscopic cyst puncture" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top; width: 200px;">using&nbsp;
                                                                <telerik:RadComboBox ID="CystPunctureDeviceComboBox" runat="server" Skin="Windows7" Width="160px" MarkFirstMatch="true" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top;">via</td>
                                                            <td style="border: none; text-align: left; vertical-align: top;">
                                                                <asp:RadioButtonList ID="CystPunctureViaRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                    RepeatDirection="vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="papilla"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="medial wall of duodenum (cyst-duodenostomy)"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="stomach (cyst-gastrostomy)"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- F's -->
                                            <!-- FineNeedleAspirationTR. Conditional: For ? SEi2 addition-->
                                            <tr id="FineNeedleAspirationTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="FineNeedleAspirationCheckBox" runat="server" Text="Fine needle aspiration" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px;">
                                                            <td style="border: none; text-align: left; padding-left: 2px; vertical-align: top;">
                                                                <div class="divChildControl" style="float: left;">
                                                                    <asp:RadioButtonList ID="FineNeedleTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="cystic lesion"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="solid lesion"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                    <!--MH added on 23 Aug 2021-->
                                                                    <br />
                                                                    <table>
                                                                        <tr>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Performed:
                                                                <telerik:RadNumericTextBox ID="FNAPerformed" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Retrieved:
                                                                <telerik:RadNumericTextBox ID="FNARetrieved" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Successful:
                                                                <telerik:RadNumericTextBox ID="FNASuccessful" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>

                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Conditional: For Duodenum Site-->
                                            <tr id="EndoscopicTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="EmrCheckBox" runat="server" Text="Endoscopic" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;">
                                                                <asp:RadioButtonList ID="EmrTypeRadioButtonList" runat="server" CssClass="rblType"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                    <asp:ListItem Value="1" Text="mucosal resection"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="submucosal dissection"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td style="border: none;"></td>
                                                            <td style="border: none; text-align: left;">
                                                                <span>using
                                                                    <telerik:RadComboBox ID="EmrFluidComboBox" runat="server" Skin="Windows7" Width="100px" MarkFirstMatch="true" />

                                                                    total volume
                                                                    <telerik:RadNumericTextBox ID="EmrFluidVolNumericTextBox" runat="server"
    
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    ml
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- FineNeedleBiopsyTR. Conditional: For ? SEi2 addition-->
                                            <tr id="FineNeedleBiopsyTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="FineNeedleBiopsyCheckBox" runat="server" Text="Fine needle biopsy" />
                                                            </td>
                                                            <!--MH added on 23 Aug 2021-->
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Performed:
                                                                <telerik:RadNumericTextBox ID="FNBPerformed" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Retrieved:
                                                                <telerik:RadNumericTextBox ID="FNBRetrieved" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Successful:
                                                                <telerik:RadNumericTextBox ID="FNBSuccessful" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- H's -->
                                            <!-- Homeostasis -->
                                            <tr id="homeostasisRowHide" runat="server" visible="true">
                                                <td style="padding: 0px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="HomeostasisCheckBox" runat="server" Checked='<%# Bind("Homeostasis")%>' Text="Homeostasis" TabIndex="60" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <telerik:RadComboBox ID="HomeostasisComboBox" runat="server" Skin="Windows7" Width="130" TabIndex="61" MarkFirstMatch="true">
                                                                    <%--   <Items>                
                                                                        <telerik:RadComboBoxItem runat="server" Text="" />
                                                                    </Items> --%>
                                                                </telerik:RadComboBox>

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- I's -->
                                            <!-- Injection: Conditional ==> Duodenum Site-->
                                            <tr id="InjectionTherapyTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="InjectionTherapyCheckBox" runat="server" Checked='<%# Bind("Injection")%>' Text="Injection therapy" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px;">
                                                                <telerik:RadComboBox ID="InjectionTypeComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="false" AllowCustomText="false" />

                                                                &nbsp;&nbsp;&nbsp;total volume
                                                                <telerik:RadNumericTextBox ID="InjectionVolumeNumericTextBox" runat="server" DbValue='<%# Bind("InjectionVolume")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                ml

                                                                &nbsp;&nbsp;&nbsp;via
                                                                <telerik:RadNumericTextBox ID="InjectionNumberNumericTextBox" runat="server" DbValue='<%# Bind("InjectionNumber")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                injections                                                                
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- M's -->
                                            <!-- Conditional: For Duodenum Site-->
                                            <tr id="MarkingTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="MarkingCheckBox" runat="server" Text="Marking" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <telerik:RadComboBox ID="MarkingTypeComboBox" runat="server" Skin="Windows7" Width="100px" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- N's -->
                                            <!-- Nasojejunal Tube. Conditional: For Duodenum Site; GastrostomyInsertion- Via Nose!-->
                                            <tr id="NasojejunalTubeTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="GastrostomyInsertionCheckBox" runat="server" Checked='<%# Bind("GastrostomyInsertion")%>' Text="Nasojejunal tube (NJT)" />
                                                            </td>
                                                            <td style="border: none;">Size
                                                                <telerik:RadNumericTextBox ID="GastrostomyInsertionSizeNumericTextBox" runat="server" DbValue='<%# Bind("GastrostomyInsertionSize")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="GastrostomyInsertionUnitsComboBox" runat="server" Skin="Windows7" Width="35px" MarkFirstMatch="true" />
                                                                <telerik:RadComboBox ID="GastrostomyInsertionTypeComboBox" runat="server" Skin="Windows7" Width="100px" MarkFirstMatch="true" />
                                                                <span style="margin-left: 15px;"></span>
                                                                Batch no
                                                                <telerik:RadTextBox ID="GastrostomyInsertionBatchNoTextBox" runat="server" Width="100px" Text='<%# Bind("GastrostomyInsertionBatchNo") %>' />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td colspan="2" style="border: none;">
                                                                <div style="float: right; padding-top: 5px">
                                                                    <telerik:RadButton ID="PEGInstructionforcareButton" runat="server" Skin="Web20" OnClick="showPEGInstruction" Text="Instructions for care..."></telerik:RadButton>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Nasojejunal Removal. Conditional: For Duodenum Site: Nasojejunal tube (NJT)-->
                                            <tr id="NasojejunalRemovalTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="NasojejunalRemovalCheckBox" runat="server" Text="Nasojejunal removal (NJT)" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- P's -->
                                            <!-- Pyloric Dilatation. Conditional: For Duodenum Site -->
                                            <tr id="PyloricDilatationTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="PyloricDilatationCheckBox" runat="server" Checked='<%# Bind("PyloricDilatation")%>' Text="Pyloric/duodenal dilatation" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PolypectomyTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PolypectomyCheckBox" runat="server" Checked='<%# Bind("Polypectomy")%>' Text="Polypectomy" TabIndex="31" />
                                                            </td>
                                                            <td style="border: none; text-align: left; visibility: hidden;">
                                                                <telerik:RadNumericTextBox ID="PolypectomyQtyRadNumericTextBox" runat="server" TabIndex="26" DbValue='<%# Bind("PolypectomyQty")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox></td>
                                                            <td style="border: none; text-align: left;">
                                                                <telerik:RadComboBox ID="PolypTypeRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true">
                                                                    <Items>
                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                    </Items>
                                                                </telerik:RadComboBox>
                                                                <%--</td>
                                                            <td style="border: none; text-align: left;">--%>
                                                                <telerik:RadButton ID="EnterPolypDetailsRadButton" runat="server" Text="Retrieval details..." Skin="Windows7" CssClass="poly-details-btn" AutoPostBack="false" />
                                                            </td>
                                                        </tr>

                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- R's -->

                                            <!-- RadioFrequencyAblationTR. Conditional: For ? SEi2 addition-->
                                            <tr id="RadioFrequencyAblationTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="RadioFrequencyAblationCheckBox" runat="server" Text="Radio frequency ablation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- S's -->
                                            <!-- Sphincterotomy: Conditional-> For PAPILLA Sites -->
                                            <tr id="SphincterotomyTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%; border: 0">
                                                        <tr headrow="1">
                                                            <td style="border: none; vertical-align: top; width: 120px;">
                                                                <asp:CheckBox ID="PapillotomyCheckBox" runat="server" Text="Sphincterotomy" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-left: 2px; width: 410px; padding-top: 8px;">sphincterotome
                                                                <telerik:RadComboBox ID="SphincterotomeComboBox" runat="server" Skin="Windows7" Width="125" MarkFirstMatch="true" />
                                                                <div id="SphincterDecompressedDiv" class="decompressTheDuctOption" runat="server" visible="false">
                                                                    <%--In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed under "Balloon trawl" tr--%>
                                                                    <asp:Label runat="server" for="SphincterDecompressedRadioButton">Decompressed the duct: </asp:Label>
                                                                    <asp:RadioButtonList ID="SphincterDecompressedRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>

                                                                <br />
                                                                <br />
                                                                length&nbsp;
                                                                <telerik:RadNumericTextBox ID="PapillotomyLengthTextBox" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="papLengthChange" />
                                                                </telerik:RadNumericTextBox>
                                                                mm  OR  accepted&nbsp;
                                                                <telerik:RadNumericTextBox ID="PapillotomyAcceptBalloonSizeTextBox" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="papSizeChange" />
                                                                </telerik:RadNumericTextBox>
                                                                mm balloon<br />
                                                                <br />


                                                                <span style="padding-bottom: 5px; background-color: #f2f0f0;">Bleeding:&nbsp;
                                                                    <asp:RadioButtonList ID="PapillotomyBleedingRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="none"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="minor"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="major"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </span>
                                                                <div id="divReasonForPapillotomy" runat="server" style="padding-top: 10px; width: 390px;">
                                                                    reason&nbsp;
                                                                    <telerik:RadComboBox ID="ReasonForPapillotomyComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="true" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td rowspan="2" colspan="2" style="border: none;">
                                                                <asp:CheckBox ID="PanOrificeSphincterotomyCheckBox" runat="server" Text="Pancreatic orifice sphincterotomy" />

                                                            </td>
                                                            <%--<td  style="border:none;text-align:left;padding-left:2px;width:410px;vertical-align:top;" >                                                              
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Condtional: Billiary / Pancreas / Papilla. NOT Duodenum -->
                                            <tr id="StoneRemovalTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="StoneRemovalCheckBox" runat="server" Text="Stone removal" />
                                                            </td>
                                                            <td colspan="2" style="border: none; text-align: left; padding-left: 2px; width: 410px;">using
                                                                <telerik:RadComboBox ID="RemovalUsingComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="true" />

                                                                <div id="StoneRemovalDecompressedDiv" class="decompressTheDuctOption" runat="server" visible="false">
                                                                    <%--In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed under "Balloon trawl" tr--%>
                                                                    <asp:Label runat="server" for="StoneRemovalDecompressedRadioButton">Decompressed the duct: </asp:Label>
                                                                    <asp:RadioButtonList ID="StoneRemovalDecompressedRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>


                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px;">
                                                            <td style="border: none; text-align: left; padding-left: 2px; vertical-align: top;">

                                                                <div class="divChildControl" style="float: left;">
                                                                    <asp:RadioButtonList ID="ExtractionOutcomeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Complete extraction"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="Fragmented"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="Partial extraction"></asp:ListItem>
                                                                        <asp:ListItem Value="4" Text="Unable to extract"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-left: 3px;">
                                                                <div id="StoneExtractDiv" class="divChildControl">
                                                                    <asp:CheckBox ID="InadequateSphincterotomyCheckBox" runat="server" Text="inadequate sphincterotomy" /><br />
                                                                    <asp:CheckBox ID="StoneSizeCheckBox" runat="server" Text="stone size" /><br />
                                                                    <asp:CheckBox ID="QuantityOfStonesCheckBox" runat="server" Text="quantity of stones" /><br />
                                                                    <asp:CheckBox ID="ImpactedStonesCheckBox" runat="server" Text="impacted stone(s)" /><br />
                                                                    <asp:CheckBox ID="OtherReasonCheckBox" runat="server" Text="other" />
                                                                    <span style="padding-left: 5px;">
                                                                        <telerik:RadTextBox ID="OtherReasonTextBox" runat="server" Width="200px" />
                                                                    </span>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Stricture Dilatation. Condtional: Billiary / Pancreas / Papilla. NOT Duodenum -->
                                            <tr id="StrictureDilatationTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StrictureDilatationCheckBox" runat="server" Text="Stricture dilatation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;">Dilated to &nbsp;
                                                                <telerik:RadNumericTextBox ID="StrictureDilatedToNumericBox" runat="server"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="StrictureDilatationUnitsComboBox" runat="server" Skin="Windows7" Width="50" MarkFirstMatch="true" />
                                                                <span style="padding-left: 10px; padding-right: 3px;">using</span>
                                                                <telerik:RadComboBox ID="StrictureDilatorTypeComboBox" runat="server" Skin="Windows7" Width="130" MarkFirstMatch="true" />
                                                                <%--Table Field Name: DilatorType--%>

                                                                <div id="StrictureDecompressedDiv" class="decompressTheDuctOption" runat="server" visible="false">
                                                                    <%--In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed under "Balloon trawl" tr--%>
                                                                    <asp:Label runat="server" for="StoneRemovalDecompressedRadioButton">Decompressed the duct: </asp:Label>
                                                                    <asp:RadioButtonList ID="StrictureDecompressedRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Generic: For ANY Site-->
                                            <tr id="StentInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentInsertionCheckBox" runat="server" Text="Stent insertion" />
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;qty
                                                                <telerik:RadNumericTextBox ID="StentInsertionQtyNumericTextBox" runat="server" CssClass="qty-number-box"

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>

                                                                <telerik:RadButton ID="StentInsertionDetailsButtons" runat="server" Text="Add/Edit insertion details" Skin="Windows7" AutoPostBack="false" />


                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td colspan="2" style="border: none;">
                                                                <span style="margin-left: 145px;">
                                                                    <asp:CheckBox ID="RadioactiveWirePlacedCheckBox" runat="server" Text="Radiotherapeutic wire placed" />
                                                                </span>
                                                                <span style="margin-left: 60px;">Batch no
                                                                    <telerik:RadTextBox ID="StentInsertionBatchNoTextBox" runat="server" Width="100px" />
                                                                </span>

                                                                <div id="divStentCorrectPlacement" class="correctPlacementAcrossStricture" runat="server" visible="false">
                                                                    <%-- if 'Duct' is selected as an Abnormaility then "Stent Placement Correctly" should displayed --%>
                                                                    <asp:Label runat="server" for="StentCorrectPlacementRadioButton">Correct placement across stricture: </asp:Label>
                                                                    <asp:RadioButtonList ID="StentCorrectPlacementRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType" onchange="toggleStentCorrectPlacement();">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>


                                                                    <span id="StentCorrectPlacementNoDiv">
                                                                        <asp:Label runat="server" for="CorrectPlacementAcrossStrictureComboBox">Reason: </asp:Label>
                                                                        <telerik:RadComboBox ID="CorrectPlacementAcrossStrictureComboBox" runat="server" Skin="Windows7" Width="200" MarkFirstMatch="true" />
                                                                    </span>
                                                                </div>
                                                                <div id="StentDecompressedDiv" class="decompressTheDuctOption" runat="server" visible="false">
                                                                    <%--In UGI : if either "Clin Obstruction CBD" or "Image Obstruction CBD" is checked in Indications then "Decompressed the duct" is displayed --%>
                                                                    <asp:Label runat="server" for="StentDecompressedRadioButton">Decompressed the duct: </asp:Label>
                                                                    <asp:RadioButtonList ID="StentDecompressedRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>


                                                            </td>
                                                        </tr>

                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Geneirc: For ANY Site-->
                                            <tr id="StentRemovalTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="StentRemovalCheckBox" runat="server" Text="Stent removal" />
                                                            </td>
                                                            <td style="border: none;">technique&nbsp;
                                                                <telerik:RadComboBox ID="StentRemovalTechniqueComboBox" runat="server" Skin="Windows7" Width="100px" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Conditional: For PAPILLA Site-->
                                            <tr id="SnareExcisionTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="SnareExcisionCheckBox" runat="server" Text="Snare excision" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- StentChangeTR. Conditional: For ? SEi2 addition-->
                                            <tr id="StentChangeTR" runat="server" visible="true">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentChangeCheckBox" runat="server" Text="Stent change" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- StentPlacementTR. Conditional: For ? SEi2 addition-->
                                            <tr id="StentPlacementTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentPlacementCheckBox" runat="server" Text="Stent placement" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Y's -->
                                            <!--YAG Laser: Conditional-> For DUODENUM Sites-->
                                            <tr id="YAGLaserTR" runat="server" visible="false">
                                                <td style="padding: 0;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; vertical-align: top">
                                                                <asp:CheckBox ID="YagLaserCheckBox" runat="server" Checked='<%# Bind("YagLaser")%>' Text="YAG laser" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px;">
                                                                <telerik:RadNumericTextBox ID="YagLaserWattsNumericTextBox" runat="server" DbValue='<%# Bind("YagLaserWatts")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                W
                                                                &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="YagLaserPulsesNumericTextBox" runat="server" DbValue='<%# Bind("YagLaserPulses")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                pulses
                                                                &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="YagLaserSecsNumericTextBox" runat="server" DbValue='<%# Bind("YagLaserSecs")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                sec
                                                                 &nbsp;&nbsp;&nbsp;

                                                                <telerik:RadNumericTextBox ID="YagLaserKJNumericTextBox" runat="server" DbValue='<%# Bind("YagLaserKJ")%>'

                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                                kJ
                                                                <%--<br /><br /><telerik:RadButton ID="YagInstructionForCareRadButton" runat="server" Text="Instructions for care..." AutoPostBack="true" OnClick="showYagInstruction" Skin="Web20" style ="display:none" />--%>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>


















                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <br />
                            &nbsp;
                        </div>
                    </asp:Panel>

                    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
                        <Windows>
                            <telerik:RadWindow ID="NPSARadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="850px" Height="750px" VisibleStatusbar="false" />
                        </Windows>
                        <Windows>
                            <telerik:RadWindow ID="PolypDetailsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Polyp details" VisibleStatusbar="false" Modal="True" Skin="Metro">
                            </telerik:RadWindow>

                            <telerik:RadWindow ID="StentInsertionDetailsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Polyp details" VisibleStatusbar="false" Modal="True" Skin="Metro">
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="StentInsertionDetailsRadWindow_old" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="850px" Height="250px" AutoSize="true" Title="Stent Insertions" VisibleStatusbar="false" Modal="True" Skin="Metro">
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow1" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="600px" Height="210px" Title="Post procedure patient care" VisibleStatusbar="false" Modal="True" Skin="Metro">
                                <ContentTemplate>
                                    <table id="table3" runat="server" cellspacing="0" cellpadding="0" border="0" style="padding-left: 15px; padding-top: 15px;">
                                        <tr>
                                            <td colspan="2" style="border: none;">
                                                <table>
                                                    <tr>
                                                        <th style="border: none; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilNilByMouthCheckBox" runat="server" Text="Nil by mouth for" AutoPostBack="false" TabIndex="83" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="OesoDilNilByMouthHrsRadNumericTextBox" runat="server" AutoPostBack="false" TabIndex="84"
                                                                
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>

                                                        <th style="border: none; text-align: left; padding-left: 35px;">
                                                            <asp:CheckBox ID="OesoDilWarmFluidsCheckBox" runat="server" Text="Warm fluids only" TabIndex="85" />
                                                        </th>
                                                        <th style="border: none;">
                                                            <telerik:RadNumericTextBox ID="OesoDilWarmFluidsHrsRadNumericTextBox" runat="server" TabIndex="86"
                                                                
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <th style="border: none; width: 140px; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilXRayCheckBox" runat="server" Text="Chest X-ray after" TabIndex="87" />
                                                        </th>
                                                        <th style="border: none;">
                                                            <telerik:RadNumericTextBox ID="OesoDilXRayHrsRadNumericTextBox" runat="server" TabIndex="88"
                                                                
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                        <th style="border: none; text-align: left; padding-left: 35px;">
                                                            <asp:CheckBox ID="OesoDilSoftDietCheckBox" runat="server" Text="Soft diet for" TabIndex="89" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="OesoDilSoftDietDaysRadNumericTextBox" runat="server" TabIndex="90"
                                                                
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">days</span>
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <th colspan="2" style="border: none; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilMedicalReviewCheckBox" runat="server" TabIndex="91"
                                                                Text="Medical review before discharge" />
                                                        </th>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 5px; padding-top: 18px;">
                                                <div id="buttonsdivwindow1" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                                                    <telerik:RadButton ID="savewindowbutton" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" TabIndex="92" Icon-PrimaryIconCssClass="telerikOkButton" />
                                                    <telerik:RadButton ID="cancelwindowbutton" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow1" TabIndex="93" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                                    <script type="text/javascript">
                                                        function closeWindow1() {
                                                            var oWnd = $find("<%= RadWindow1.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow2" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="500px" Height="240px" Title="YAG laser treatment instructions for care" VisibleStatusbar="false" Modal="true" Skin="Metro">
                                <ContentTemplate>
                                    <table id="table1" runat="server" border="0" style="padding-left: 15px; padding-top: 15px;">
                                        <tr>
                                            <td colspan="2" style="border: none;">
                                                <table>
                                                    <tr>
                                                        <th style="border: none; width: 150px; text-align: left;">
                                                            <asp:CheckBox ID="YAGDilNilByMouthCheckBox" runat="server" Text="Nil by mouth for" AutoPostBack="false" TabIndex="94" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="YAGDilNilByMouthHrsRadNumericTextBox" runat="server" AutoPostBack="false" TabIndex="95"
                                                                
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                        <tr>
                                                            <tr>
                                                                <th style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilWarmFluidsCheckBox" runat="server" Text="Warm fluids only" TabIndex="96" />
                                                                </th>
                                                                <th style="border: none; text-align: left;">
                                                                    <telerik:RadNumericTextBox ID="YagDilWarmFluidsHrsRadNumericTextBox" runat="server" TabIndex="97"
    
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="45px"
                                                                        MinValue="0" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    <span style="font-weight: normal;">hours</span>
                                                                </th>
                                                            </tr>
                                                            <tr>
                                                                <th style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilSoftDietCheckBox" runat="server" Text="Soft diet for" TabIndex="98" />
                                                                </th>
                                                                <th style="border: none; text-align: left;">
                                                                    <telerik:RadNumericTextBox ID="YagDilSoftDietDaysRadNumericTextBox" runat="server" TabIndex="99"
    
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="45px"
                                                                        MinValue="0" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    <span style="font-weight: normal;">days</span>
                                                                </th>
                                                            </tr>
                                                            <tr>
                                                                <th colspan="2" style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilMedicalReviewCheckBox" runat="server" TabIndex="100"
                                                                        Text="Medical review before discharge" />
                                                                </th>
                                                            </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px; padding-top: 18px;">
                                                <div id="buttonsdivwindow2">
                                                    <telerik:RadButton ID="Window2SaveRadButton" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" TabIndex="101" Icon-PrimaryIconCssClass="telerikOkButton" />
                                                    <telerik:RadButton ID="Window2CancelRadButton" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow2" TabIndex="102" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                                    <script type="text/javascript">
                                                        function closeWindow2() {
                                                            var oWnd = $find("<%= RadWindow2.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow3" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="650px" Height="220px" Title="Insertion instructions for care" VisibleStatusbar="false" Modal="true" Skin="Metro">
                                <ContentTemplate>
                                    <table id="tablepeg" runat="server" border="0">
                                        <tr>
                                            <td>
                                                <fieldset id="PEGInsertionFieldset" runat="server" style="margin-left: 30px; border: #83AABA solid 1px;">
                                                    <legend>PEG Insertion instructions for care</legend>
                                                    <div>
                                                        <asp:CheckBox ID="NilByMouthCheckBox" runat="server" Checked='<%# Bind("NilByMouth")%>' Text="Nil by mouth for" TabIndex="103" />
                                                        <telerik:RadNumericTextBox ID="NilByMouthHrsNumericTextBox" runat="server" TabIndex="104" DbValue='<%# Bind("NilByMouthHrs")%>'
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs

                                            &nbsp;&nbsp;&nbsp;&nbsp;
                                            <asp:CheckBox ID="NilByProcCheckBox" runat="server" Checked='<%# Bind("NilByProc")%>' Text="Nil by PEG for" TabIndex="105" />
                                                        <telerik:RadNumericTextBox ID="NilByProcHrsNumericTextBox" runat="server" TabIndex="106" DbValue='<%# Bind("NilByProcHrs")%>'
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs

 
                                                    </div>
                                                    <br />
                                                    <div>
                                                        <asp:CheckBox ID="AttachmentToWardCheckBox" runat="server" Checked='<%# Bind("AttachmentToWard")%>'
                                                            Text="All attachments for feeding returned to the ward with patient" TabIndex="108" />
                                                    </div>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdivwindow3">
                                                    <br />
                                                    <br />
                                                    <telerik:RadButton ID="RadButton1" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" TabIndex="109" />
                                                    <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow3" TabIndex="110" />
                                                    <script type="text/javascript">
                                                        function closeWindow3() {
                                                            var oWnd = $find("<%= RadWindow3.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new entry"
                                KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                                <ContentTemplate>
                                    <table cellspacing="3" cellpadding="3" style="width: 100%">
                                        <tr>
                                            <td>
                                                <br />
                                                <div class="left">
                                                    <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                                    <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                                    &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>

                        </Windows>
                    </telerik:RadWindowManager>
                    <%--</form>--%>

                    <telerik:RadWindowManager ID="RadWindowManager2" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
                        <Windows>
                            <telerik:RadWindow ID="RadWindow4" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="450px" Height="260px" Title="Insertion instructions for care" VisibleStatusbar="false" Modal="true" Skin="Metro">
                                <ContentTemplate>
                                    <table id="table2" runat="server" border="0">
                                        <tr>
                                            <td>
                                                <fieldset id="Fieldset1" runat="server" style="margin-left: 10px; margin-top: 10px; padding-right: 30px; border: #83AABA solid 1px;">
                                                    <legend>NJT insertion instructions for care</legend>
                                                    <div>
                                                        <br />
                                                        <asp:CheckBox ID="CheckBox1" runat="server" Checked='<%# Bind("NilByMouth")%>' Text="Nil by mouth for" Width="120px" />
                                                        <telerik:RadNumericTextBox ID="RadNumericTextBox1" runat="server" DbValue='<%# Bind("NilByMouthHrs")%>'
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs

                                                                        <br />
                                                        <asp:CheckBox ID="CheckBox2" runat="server" Checked='<%# Bind("NilByProc")%>' Text="Nil by NJT for" Width="120px" />
                                                        <telerik:RadNumericTextBox ID="RadNumericTextBox2" runat="server" DbValue='<%# Bind("NilByProcHrs")%>'
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs
                                                    </div>
                                                    <br />
                                                    <div>
                                                        <asp:CheckBox ID="CheckBox3" runat="server" Checked='<%# Bind("AttachmentToWard")%>'
                                                            Text="All attachments for feeding returned to the ward with patient" />
                                                    </div>
                                                    <br />
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdivwindow3" style="margin-left: 10px; margin-top: 10px;">
                                                    <telerik:RadButton ID="RadButton3" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" />
                                                    <telerik:RadButton ID="RadButton4" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow3" />
                                                    <script type="text/javascript">
                                                        function closeWindow3() {
                                                            var oWnd = $find("<%= RadWindow3.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow5" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
                                KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                                <ContentTemplate>
                                    <table cellspacing="3" cellpadding="3" style="width: 100%">
                                        <tr>
                                            <td>
                                                <br />
                                                <div class="left">
                                                    <telerik:RadTextBox ID="RadTextBox1" runat="Server" Width="250px" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                                    <telerik:RadButton ID="RadButton5" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                                    &nbsp;&nbsp;
                                        <telerik:RadButton ID="RadButton6" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>

                        </Windows>
                    </telerik:RadWindowManager>

                    <script type="text/javascript">

                        var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
                        var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

                        $($find("#<%= RadWindow3.ClientID%>")).ready(function () {

                            $("#<%= NilByMouthCheckBox.ClientID%>").click(function () {
                                if ($("#<%= NilByMouthCheckBox.ClientID%>").is(':checked')) {
                                    $("#<%= NilByMouthHrsNumericTextBox.ClientID%>").val("<%--= NilByMouthHrs--%>");
                                } else {
                                    $("#<%--=NilByMouthHrsNumericTextBox.ClientID--%>").val("0");
                                }
                            });
                            $("#<%= NilByMouthHrsNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=NilByMouthHrsNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= NilByMouthCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= NilByMouthCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= NilByProcCheckBox.ClientID%>").click(function () {
                                if ($("#<%= NilByProcCheckBox.ClientID%>").is(':checked')) {
                                    $("#<%= NilByProcHrsNumericTextBox.ClientID%>").val("<%--= NilByProcHrs--%>");
                                } else {
                                    $("#<%=NilByProcHrsNumericTextBox.ClientID%>").val("0");
                                }
                            });
                            $("#<%= NilByProcHrsNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=NilByProcHrsNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= NilByProcCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= NilByProcCheckBox.ClientID%>").prop('checked', true);
                                }
                            });
                        });

                        function papLengthChange(sender, eventArgs) {
                            if ($("#<%=PapillotomyLengthTextBox.ClientID%>").val() > 0) {
                                $("#<%=PapillotomyAcceptBalloonSizeTextBox.ClientID%>").val("");
                            }
                        }

                        function papSizeChange(sender, eventArgs) {
                            if ($("#<%=PapillotomyAcceptBalloonSizeTextBox.ClientID%>").val() > 0) {
                                $("#<%=PapillotomyLengthTextBox.ClientID%>").val("");
                            }
                        }

                        function showStentInsertionsWindow(qtyControlId) {
                            if (parseInt($("#" + qtyControlId).val()) > 0) {
                                var url = "<%= ResolveUrl("~/Products/Gastro/TherapeuticProcedures/StentInsertionDetails.aspx?therapeuticId={0}&qty={1}&area={2}")%>";
                                url = url.replace("{0}", "<%--=TherapeuticProcedureId--%>");
                                url = url.replace("{1}", $("#" + qtyControlId).val());
                                url = url.replace("{2}", "<%--=sArea--%>");

                                var oWnd = $find("<%= StentInsertionDetailsRadWindow.ClientID %>");
                                oWnd._navigateUrl = url
                                oWnd.set_title("Stent Insertions");

                                //Add the name of the function to be executed when RadWindow is closed.
                                //oWnd.add_close(OnClientClose);
                                oWnd.show();
                            }
                        }




                    </script>













                </telerik:RadPane>
                <!-- Following is a seperate RadPane for Buttons and 'OtherText' input control -->
                <telerik:RadPane ID="ButtonsRadPane" runat="server" Width="680px" Height="120px" Scrolling="None" CssClass="TherapeuticDetailsButtonsPane" BorderStyle="None" BorderWidth="0px">
                    <div id="cmdOtherData">
                        <div class="shaded-tab-header" style="padding: 10px 0px 0 20px; width: 680px; margin-bottom: 10px; height: 32px; box-sizing: content-box">
                            <label for="OtherTextBox" style="padding-right: 15px;">Other</label>
                            <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="550px" TabIndex="83" />
                        </div>

                        <div class="shaded-tab-header" style="padding: 10px 0px 0 20px; width: 680px; margin-bottom: 10px; height: 32px; box-sizing: content-box;display:none;">
                            <table style="width: 95%;">
                                <tr>

                                    <td style="text-align: right;">
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicked="disableSaveButton" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </telerik:RadPane>
            </telerik:RadSplitter>
        </div>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>

</body>
<telerik:RadScriptBlock runat="server">
<script type="text/javascript">
    var ercpTherapeuticProceduresValueChanged = false;    

    $(window).on('load', function () {
        $('input[type="checkbox"]').each(function () {
            ToggleTRs($(this));
        });
        $('input[type="checkbox"]').on('click', function () {
            ToggleTRs($(this));
        });

        toggleStentCorrectPlacement();
    });

    var UserControlPrefix = ''; //## Global Variable!
    var clicks = 0;

    function disableSaveButton() {
        //This will stop Clicky McClickface clicking on the save button over and over again causing multiple records to be created in the database
        clicks = clicks + 1;
        if (clicks == 1)
            return true;
        else {
            $('#SaveButton').prop('disabled', true);
            return false;
        }
    }
    //#### This will return the prefix of the UserControl- to know - where was the Event triggerred from!
    function getCurrentUC_Prefix(fullControlName) {
        //console.log("function getCurrentUC_Prefix(fullControlName): " + fullControlName + '    vs     TherapeuticProcedureERCPTrainEE');
        //return fullControlName.indexOf("TherapeuticProcedureERCPTrainEE") >= 0 ? '#TherapeuticProcedureERCPTrainEE_' : '#TherapeuticProcedureERCPTrainER_';
    };

    function updatePolypsQty() {
        $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest('update-polyps');
    }
    function savePage() {
        $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
    }

    $(document).ready(function () {
        $('#<%=EnterPolypDetailsRadButton.ClientID%>').on('click', function () {
            var selectedPolypType = $find('<%=PolypTypeRadComboBox.ClientID%>').get_text().toLowerCase();
            var polypQty = $find('<%=PolypectomyQtyRadNumericTextBox.ClientID%>').get_value();
            if (selectedPolypType == '') {
                alert('Please select a polyp type');
            }
            else {
                var url = "<%= ResolveUrl("../Abnormalities/Common/PolypDetails.aspx?type={0}&siteid={1}&qty={2}")%>";
                url = url.replace("{0}", selectedPolypType);
                url = url.replace("{1}", <%=siteId%>);
                url = url.replace("{2}", polypQty);

                var oWnd = $find("<%= PolypDetailsRadWindow.ClientID %>");
                oWnd._navigateUrl = url
                oWnd.set_title("Polyp details");
                oWnd.add_close(updatePolypsQty)
                oWnd.show();
            }
            return false;
        });

        $('[id$=StoneExtractDiv]').hide();
        //$("[id$=OtherReasonTextBox]").hide();

        ToggleStoneRemoval();   //### To show the [StoneExtractDiv] If 'Partial extraction' or 'Unable to extract' was Selected as 'Extraction Outcome'

        $('#radMultiTherapPageViews tr td:first-child input[type=checkbox], input[type=radio]').change(function () {
            //$('[id^=TherapeuticProcedureERCPTrainE] tr td:first-child input[type=checkbox], input[type=radio]').change(function () {
            ToggleTRs($(this));
            //var otherControlId = this.id.search(/trainee/i) > 0 ? this.id.replace("ProcedureERCPTrainEE", "ProcedureERCPTrainER") : this.id.replace("ProcedureERCPTrainER", "ProcedureERCPTrainEE");
            //$("#" + otherControlId).closest('tr').find("input").prop("disabled", $(this).is(':checked'));
            //## Uncheck the 'chkNoneCheckBox' if it was Checked!
            $('#<%=chkNoneCheckBox.ClientID%>').prop("checked", false);

        });

        $('#TherapeuticsTable tr td:first-child input[type=checkbox], input[type=radio], input[type=text]').change(function () {
            if ($(this).is('[type=checkbox]') || $(this).is('[type=radio]')) {
                ToggleTRs($(this));
                $('#<%=chkNoneCheckBox.ClientID%>').prop("checked", false);
            }
            ercpTherapeuticProceduresValueChanged = true;
        });

        $('#<%=chkNoneCheckBox.ClientID%>').on('click', function () {
            if ($(this).is(':checked')) {
                ToggleNoneCheckBox(true);
                $("#<%= OtherTextBox.ClientID %>").val("");
            }
            ercpTherapeuticProceduresValueChanged = true;
        })

        $("[id$=StoneRemovalCheckBox]").on('change', function () {
            //### Specially for 'StoneRemovalCheckBox'. Need to hide the 'StoneExtractDiv' when Unchecking..
            if (!$(this).is(':checked')) {
                ToggleStoneRemoval();
                $("[id$=StoneExtractDiv]").hide();
                //console.log('StoneRemovalCheckBox=> No more checked.. Unchecked => ' + this.name);
            }
        });

        $("[id$=RFACheckBox]", '[id$=RFATypeRadioButtonList]').change(function () {
            ShowRFADiv(getCurrentUC_Prefix(this.name));
        });

        $('[id$=ExtractionOutcomeRadioButtonList] input').change(function () {
            ToggleStoneRemoval();
        });

        $('[id$=EmrTypeRadioButtonList]').on('change', function (event) {
            //var currentControl = event.target;                //ShowEndoscopic(getCurrentUC_Prefix(currentControl.id));
            ShowEndoscopic(getCurrentUC_Prefix(this.name));
        });

        $('[id$=OtherReasonCheckBox]').change(function (event) {
            //var thisName = event.target;
            //var otherCheckBox = this.id;
            //var trainER_TextBox = '#TherapeuticProcedureERCPTrainER_OtherReasonTextBox';
            //var OtherReasonTextBox = (otherCheckBox.indexOf("ERCPTrainER") > 0 ? trainER_TextBox : '#TherapeuticProcedureERCPTrainEE_OtherReasonTextBox');
            //$(OtherReasonTextBox).toggle();
        });

        $('#form1').on('change', function () {
            valueChanged();
        });

        //Added by rony tfs-4166;
        $(window).on('beforeunload', function () {
            if (ercpTherapeuticProceduresValueChanged) { $('#<%=SaveButton.ClientID%>').click(); }
        });
        $(window).on('unload', function () {
            localStorage.clear();
            setRehideSummary();
        });
    });

    function valueChanged() {
        setTimeout(function () {
            var valueToSave = false;
            $("#TherapeuticsTable tr td:first-child").each(function () {
                if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
            });
            if (!$('#chkNoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');

        }, 10);
    }

    function UpdateYagLaserKJ(sender, eventArgs) {
        if (event != undefined) {
            var currentControl = event.target;
            //console.log("function UpdateYagLaserKJ: currentUc ==> " + currentControl.id);
            var currentUc = getCurrentUC_Prefix(currentControl.id);

            var YagLaserWatts = $.trim($(currentUc + 'YagLaserWattsNumericTextBox').val());
            var YagLaserPulses = $.trim($(currentUc + 'YagLaserPulsesNumericTextBox').val());
            var YagLaserSecs = $.trim($(currentUc + 'YagLaserSecsNumericTextBox').val());
            if ((YagLaserWatts == '') || (YagLaserPulses == '') || (YagLaserSecs == '')) {
                $(currentUc + 'YagLaserKJNumericTextBox').val(0);
            } else {
                $(currentUc + 'YagLaserKJNumericTextBox').val((YagLaserWatts * YagLaserPulses * YagLaserSecs) / 1000);
            }
        }
    };

    function UpdateArgonBeamKJ(sender, eventArgs) {
        if (event != undefined) {
            var currentControl = event.target;
            var currentUc = getCurrentUC_Prefix(currentControl.id);
            //console.log("function UpdateArgonBeamKJ: currentUc ==> " + currentControl.id);

            var ArgonBeamDiathermyWatts = $.trim($(currentUc + 'ArgonBeamDiathermyWattsNumericTextBox').val());
            var ArgonBeamDiathermyPulses = $.trim($(currentUc + 'ArgonBeamDiathermyPulsesNumericTextBox').val());
            var ArgonBeamDiathermySecs = $.trim($(currentUc + 'ArgonBeamDiathermySecsNumericTextBox').val());
            if ((ArgonBeamDiathermyWatts == '') || (ArgonBeamDiathermyPulses == '') || (ArgonBeamDiathermySecs == '')) {
                $(currentUc + 'ArgonBeamDiathermyKJNumericTextBox').val(0);
            } else {
                $(currentUc + 'ArgonBeamDiathermyKJNumericTextBox').val((ArgonBeamDiathermyWatts * ArgonBeamDiathermyPulses * ArgonBeamDiathermySecs) / 1000);
            }
        }
    }

    function hideTR(vArea) { //## Not used!
        switch (vArea) {
            case 'Oesophagus':
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PolypectomyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_GastrostomyInsertionTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_GastrostomyRemovalTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PyloricDilatationTR").hide();
                break;
            case 'Stomach':
                $(UserControlPrefix + "ERCPTherapeuticsFormView_OesophagealDilatationTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PyloricDilatationTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_RadioFrequencyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_ProbeInsertionTR").hide();
                break;
            case 'Duodenum':
                $(UserControlPrefix + "ERCPTherapeuticsFormView_OesophagealDilatationTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PolypectomyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealSclerotherapyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealBandingTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealClipTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_RadioFrequencyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_ProbeInsertionTR").hide();
                break;
            default:
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PolypectomyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_GastrostomyInsertionTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_GastrostomyRemovalTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PyloricDilatationTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_OesophagealDilatationTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_PolypectomyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealSclerotherapyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealBandingTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_VaricealClipTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_RadioFrequencyTR").hide();
                $(UserControlPrefix + "ERCPTherapeuticsFormView_ProbeInsertionTR").hide();
        }
    }

    function CloseWindow() {
        window.parent.CloseWindow();
    }

    function ToggleTRs(chkbox) {
        if (chkbox[0].id == "ScopePassCheckBox") { return; }
        if (chkbox[0].id == "EmrCheckBox") {
            if (chkbox.is(':checked')) {
                if (!$(UserControlPrefix + 'EmrTypeRadioButtonList_1').is(':checked'))
                    $(UserControlPrefix + "EmrTypeRadioButtonList_0").prop('checked', true);
            }
            else {
                $(UserControlPrefix + "EmrTypeRadioButtonList_0").attr('checked', false);
                $(UserControlPrefix + "EmrTypeRadioButtonList_1").attr('checked', false);
            }
        }
        if (chkbox[0].id != "NoneCheckBox") {
            var checked = chkbox.is(':checked');
            if (checked) {
                $(UserControlPrefix + "NoneCheckBox").attr('checked', false);
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

        if ((chkbox[0].id.indexOf("PapillotomyCheckBox") > 0 || (chkbox[0].id.indexOf("PanOrificeSphincterotomyCheckBox") > 0))) { TogglePapillotomy(chkbox); }
    }



        <%'Reason for Papillotomy to be hidden/shown based on Sphincterotomy checkbox %>
    function TogglePapillotomy(chkbox) {
        var UserControlPrefix = chkbox[0].id.indexOf("TherapeuticProcedureERCPTrainEE") >= 0 ? 'TherapeuticProcedureERCPTrainEE_' : 'TherapeuticProcedureERCPTrainER_';
        if (((chkbox[0].id.indexOf("PapillotomyCheckBox") >= 0) || (chkbox[0].id.indexOf("PanOrificeSphincterotomyCheckBox") >= 0))
            && ($('#' + UserControlPrefix + 'PapillotomyCheckBox').is(':checked'))) {
            $('#' + UserControlPrefix + "divReasonForPapillotomy").show();
        }
        else {
            $('#' + UserControlPrefix + "divReasonForPapillotomy").hide();
        }
    }

    function ToggleNoneCheckBox(checked) {
        <%--if (checked) { //TherapeuticProcedureERCPTrainEE_TherapeuticsTable                
            $("[id$=TherapeuticsTable] tr td:first-child").each(function () {
                $(this).find("input:checkbox:checked, input:radio:checked").removeAttr("checked");
                $(this).find("input:checkbox").trigger("change");
                $(this).find("input:text").val("");
                ToggleStoneRemoval();
            });
            $('#<%=chkNoneCheckBox.ClientID%>').prop("checked", true);
        }--%>
        if (checked) {
            $("#TherapeuticsTable tr td:first-child").each(function () {
                $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                $(this).find("input:checkbox").trigger("change");
                ToggleStoneRemoval();
            });
            $("#chkNoneCheckBox").prop("checked", true);
        }
    }

    function ToggleStoneRemoval() {
        var parentCtrlId = "StoneExtractDiv";
        var checkedRadio = $('[id$=ExtractionOutcomeRadioButtonList] input:checked');
        var selectedVal = checkedRadio.val();
        //### Remove "due to" from the last two Options
        $('[id$=ExtractionOutcomeRadioButtonList] input:radio').each(function () {
            var curTxt = $(this).next().html();
            if (curTxt.indexOf(" due to") >= 0) {
                $(this).next().html(curTxt.replace(/ due to/g, ''));
            }
        });

        if (selectedVal == undefined || selectedVal < 3) {
            ClearControls_DIV(parentCtrlId);
            $('[id$=StoneExtractDiv]').hide();
            //$(parentCtrlId).hide();
            //$("[id$=StoneExtractDiv]");
            //$(this).closest('td').next('td').find('#StoneExtractDiv').addClass("hidden");
            //$(this).next("td div").addClass("hidden");
        } else {
            $('[id$=StoneExtractDiv]').show();
            checkedRadio.next().html(checkedRadio.next().html() + " due to");
            $("[id$=StoneExtractDiv]").find("input:checkbox").trigger("change");

            //$(this).closest('td').next('td').find('#StoneExtractDiv').removeClass("hidden");
            //$(this).parents('tr').children().find('#StoneExtractDiv').removeClass("hidden");
            //$(this).next("td div").removeClass("hidden");
            ////$("#" + parentCtrlId).show();
            //ShowStoneExtractOtherCB();
        }
    }


    //## ShowStoneExtractOtherCB() => Not used anymore; Shawkat;
    //function ShowStoneExtractOtherCB(thisControl) {
    //    //console.log("thisControl: " + thisControl);
    //    var trainER_TextBox = '#TherapeuticProcedureERCPTrainER_OtherReasonTextBox';
    //    var OtherReasonTextBox = (thisControl.indexOf("ERCPTrainER") > 0 ? trainER_TextBox : '#TherapeuticProcedureERCPTrainEE_OtherReasonTextBox');
    //    //$(OtherReasonTextBox).show($(this).is(":checked"));
    //    if ($(this).is(":checked")) {
    //        $(OtherReasonTextBox).removeClass('hidden');
    //    } else { $(OtherReasonTextBox).addClass('hidden'); }
    //}

    function ClearControls(tableCell) {
        tableCell.find("input:radio:checked").removeAttr("checked");
        tableCell.find("input:checkbox:checked").removeAttr("checked");
        tableCell.find("input:text").val("");
        if ($(UserControlPrefix + "NoneCheckBox").is(':checked')) {
            $(UserControlPrefix + "OtherTextBox").val("");
        }
    }

    function ClearControls_DIV(parentCtrlId) {
        $("#" + parentCtrlId + " input:radio:checked").removeAttr("checked");
        $("#" + parentCtrlId + " input:checkbox:checked").removeAttr("checked");
        $("#" + parentCtrlId + " input:text").val('');
        $("#" + parentCtrlId + " textarea").val('');

        $("#" + parentCtrlId).find("input:checkbox").trigger("change");
        //console.log('function ClearControls_DIV(parentCtrlId)==> ALL DONE!');
    }

    function ShowEndoscopic(UserControlPrefix) {
        if ($(UserControlPrefix + 'EmrTypeRadioButtonList_0').is(':checked') || ($(UserControlPrefix + 'EmrTypeRadioButtonList_1').is(':checked'))) {
            if (!$(UserControlPrefix + "EmrCheckBox").is(':checked')) {
                $(UserControlPrefix + "EmrCheckBox").prop('checked', true);
                ToggleTRs($(UserControlPrefix + "EmrCheckBox"));
            }
        }
    }

    function ShowRFADiv(UserControlPrefix) {
        if ($(UserControlPrefix + 'RFATypeRadioButtonList_0').is(':checked')) {
            $(UserControlPrefix + "ERCPTherapeuticsFormView_RFADiv").show();
            $('.RFANumSegTreatedSpan').html('No. of 3cm segments treated');
            $('.RFANumTimesSegTreatedSpan').html('No. of times each segment treated (1-2)');
        } else if ($(UserControlPrefix + 'RFATypeRadioButtonList_1').is(':checked')) {
            $(UserControlPrefix + "ERCPTherapeuticsFormView_RFADiv").show();
            $('.RFANumSegTreatedSpan').html('No. of segments treated (1 to 40)');
            $('.RFANumTimesSegTreatedSpan').html('No. of times each segment treated (1-4)');
        } else {
            $(UserControlPrefix + "RFADiv").hide();
        }
    }


    //function OtherChanged() {
    $("#<%=OtherTextBox.ClientID%>").on("input", function () {
        if (!$('#<%= chkNoneCheckBox.ClientID%>').is(':checked')) { return; }
        if ($('#<% = OtherTextBox.ClientID%>').val() != '') {
            $('#<% = chkNoneCheckBox.ClientID%>').removeAttr("checked");
        }
    });

    function showNPSAAlert() { //## Not used anywhere!
        radopen("../../Common/WordLibrary.aspx?option=NPSAAlert", "Word Library", "710px", "610px");
    }

    function toggleStentCorrectPlacement() {
        var selectedVal = $('#StentCorrectPlacementRadioButton input:checked').val();

        if (selectedVal == undefined) {
            hideStentCorrectPlacementNo();
        }

        if (selectedVal == 0) {
            $("#StentCorrectPlacementNoDiv").show();
        } else {
            hideStentCorrectPlacementNo();
        }
    }

    function hideStentCorrectPlacementNo() {
        $("#StentCorrectPlacementNoDiv").hide();
        var combo = $find("<%= CorrectPlacementAcrossStrictureComboBox.ClientID %>");
        if (combo != null)
            combo.clearSelection();
    }
</script>
</telerik:RadScriptBlock>
</html>
