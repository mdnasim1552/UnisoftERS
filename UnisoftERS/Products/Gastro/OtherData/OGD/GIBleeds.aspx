<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_GIBleeds" CodeBehind="GIBleeds.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Rockall and Blatchford scores</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .tableWithNoBorders {
            border: none;
        }

            .tableWithNoBorders td {
                border: none;
                height: 15px;
            }

            .ProgressBarUnitsContainer {
    margin: 0 30px;
}
 
.ProgressBarSkinName {
    display: inline-block;
    *zoom: 1;
    *display: inline;
    font-family: Arial;
    font-weight: normal;
    width: 25%;
    white-space:nowrap;
}
 
.ProgressBarUnit {
    margin-top: 0px;
}
    </style>
    
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            $(document).ready(function () {
                
            });

            (function (global, undefined) {
                var gibleeds = window.gibleeds = window.gibleeds || {},
                    rockallProgressBar,
                    blatchfordProgressBar,
                    rebleedProgressBar,
                    adverseeventProgressBar,
                    mortalityProgressBar;

                function rockallProgressBar_load(sender, args) {
                    rockallProgressBar = sender;
                }

                function blatchfordProgressBar_load(sender, args) {
                    blatchfordProgressBar = sender;
                }

                function rebleedProgressBar_load(sender, args) {
                    rebleedProgressBar = sender;
                }

                function adverseeventProgressBar_load(sender, args) {
                    adverseeventProgressBar = sender;
                }

                function mortalityProgressBar_load(sender, args) {
                    mortalityProgressBar = sender;
                }

                initialize = function () {
                    updateProgressBar();
                };

                var rockallScore = 0;
                var blatchfordScore = 0;
                var riskBleed = 0;
                var estMortality = 0;
                var riskOfAdverseEvent = 0;

                updateProgressBar = function () {
                    var bs = 0
                    var rs = 0;
                    var ageValue = convertToInt($find('AgeDropDownList').get_selectedItem().get_value());
                    var genderValue = convertToInt($('#GenderRadioButtonList input:checked').val());

                    var melaenaValue = convertToInt($('#MelaenaRadioButtonList input:checked').val());
                    var syncopeValue = convertToInt($('#SyncopeRadioButtonList input:checked').val());
                    var heartFailureValue = convertToInt($('#HeartFailureRadioButtonList input:checked').val());
                    var liverFailureValue = convertToInt($('#LiverFailureRadioButtonList input:checked').val());
                    var renalFailureValue = convertToInt($('#RenalFailureRadioButtonList input:checked').val());
                    var metastaticCancerValue = convertToInt($('#MetastaticCancerRadioButtonList input:checked').val());
                    var lowestSystolicBPValue = convertToInt($find('LowestSystolicBPDropDownList').get_selectedItem().get_value());
                    var highestPulseValue = convertToInt($('#HighestPulseRadioButtonList input:checked').val());
                    var ureaValue = convertToInt($find('UreaDropDownList').get_selectedItem().get_value());
                    var haemoglobinValue = convertToInt($find('HaemoglobinDropDownList').get_selectedItem().get_value());
                    var diagnosisValue = convertToInt($find('DiagnosisDropDownList').get_selectedItem().get_value());
                    var bleedingValue = convertToInt($find('BleedingDropDownList').get_selectedItem().get_value());

                    rockallScore = 0;
                    blatchfordScore = 0;
                    riskBleed = 0;
                    estMortality = 0;
                    riskOfAdverseEvent = 0;

                    bs = 0; rs = 0;
                    if (ageValue == 2 || ageValue == 3) {
                        rockallScore = rockallScore + ageValue - 1;
                        bs = 0; rs = ageValue - 1;
                    }
                    displayScore("AgeScoreLabel", bs, rs);
                    
                    bs = 0; rs = 0;
                    if (melaenaValue == 2) {
                        blatchfordScore = blatchfordScore + 2;
                        bs = 1; rs = 0;
                    }
                    displayScore("MelaenaScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (syncopeValue == 2) {
                        blatchfordScore = blatchfordScore + 2;
                        bs = 2; rs = 0;
                    }
                    displayScore("SyncopeScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (lowestSystolicBPValue == 2) {
                        blatchfordScore = blatchfordScore + 1;
                        bs = 1; rs = 0;
                    }
                    else if (lowestSystolicBPValue == 3) {
                        blatchfordScore = blatchfordScore + 2;
                        rockallScore = rockallScore + 2;
                        bs = 2; rs = 2;
                    }
                    else if (lowestSystolicBPValue == 4) {
                        blatchfordScore = blatchfordScore + 3;
                        rockallScore = rockallScore + 2;
                        bs = 3; rs = 2;
                    }
                    displayScore("LowestSystolicBPScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (highestPulseValue == 2) {
                        blatchfordScore = blatchfordScore + 1;
                        rockallScore = rockallScore + 1;
                        bs = 1; rs = 1;
                    }
                    displayScore("HighestPulseScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (ureaValue == 2) {
                        blatchfordScore = blatchfordScore + 2;
                        bs = 2; rs = 0;
                    }
                    else if (ureaValue == 3) {
                        blatchfordScore = blatchfordScore + 3;
                        bs = 3; rs = 0;
                    }
                    else if (ureaValue == 4) {
                        blatchfordScore = blatchfordScore + 4;
                        bs = 4; rs = 0;
                    }
                    else if (ureaValue == 5) {
                        blatchfordScore = blatchfordScore + 6;
                        bs = 6; rs = 0;
                    }
                    displayScore("UreaScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (haemoglobinValue == 2) {
                        if (genderValue == 1) {
                            blatchfordScore = blatchfordScore + 1;
                            bs = 1; rs = 0;
                        }
                    }
                    else if (haemoglobinValue == 3) {
                        if (genderValue == 1) {
                            blatchfordScore = blatchfordScore + 3;
                            bs = 3; rs = 0;
                        }
                        else {
                            blatchfordScore = blatchfordScore + 1;
                            bs = 1; rs = 0;
                        }
                    }
                    else if (haemoglobinValue == 4) {
                        blatchfordScore = blatchfordScore + 6;
                        bs = 6; rs = 0;
                    }
                    displayScore("HaemoglobinScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (heartFailureValue == 2) {
                        blatchfordScore = blatchfordScore + 2;
                        rockallScore = rockallScore + 2;
                        bs = 2; rs = 2;
                    }
                    displayScore("HeartFailureScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (liverFailureValue == 2) {
                        blatchfordScore = blatchfordScore + 2;
                        rockallScore = rockallScore + 3;
                        bs = 2; rs = 3;
                    }
                    displayScore("LiverFailureScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (renalFailureValue == 2) {
                        rockallScore = rockallScore + 3;
                        bs = 0; rs = 3;
                    }
                    displayScore("RenalFailureScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (metastaticCancerValue == 2) {
                        rockallScore = rockallScore + 3;
                        bs = 0; rs = 3;
                    }
                    displayScore("MetastaticCancerScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (diagnosisValue == 3) {
                        rockallScore = rockallScore + 1;
                        bs = 0; rs = 1;
                    }
                    else if (ureaValue == 4) {
                        rockallScore = rockallScore + 2;
                        bs = 0; rs = 2;
                    }
                    displayScore("DiagnosisScoreLabel", bs, rs);

                    bs = 0; rs = 0;
                    if (bleedingValue >= 2) {
                        rockallScore = rockallScore + 2;
                        bs = 0; rs = 2;
                    }
                    displayScore("BleedingScoreLabel", bs, rs);
                    
                    switch (rockallScore) {
                        case 0:
                            riskBleed = 5;
                            break;
                        case 1:
                            riskBleed = 3;
                            break;
                        case 2:
                            riskBleed = 5;
                            break;
                        case 3:
                            riskBleed = 11;
                            break;
                        case 4:
                            riskBleed = 14;
                            break;
                        case 5:
                            riskBleed = 24;
                            break;
                        case 6:
                            riskBleed = 33;
                            break;
                        case 7:
                            riskBleed = 44;
                            break;
                        default:
                            riskBleed = 42;
                            break;
                    }

                    switch (rockallScore) {
                        case 0:
                            estMortality = 0;
                            break;
                        case 1:
                            estMortality = 0;
                            break;
                        case 2:
                            estMortality = 0;
                            break;
                        case 3:
                            estMortality = 3;
                            break;
                        case 4:
                            estMortality = 5;
                            break;
                        case 5:
                            estMortality = 11;
                            break;
                        case 6:
                            estMortality = 17;
                            break;
                        case 7:
                            estMortality = 27;
                            break;
                        default:
                            estMortality = 41;
                            break;
                    }

                    switch (blatchfordScore) {
                        case 0:
                            riskOfAdverseEvent = 2;
                            break;
                        case 1:
                            riskOfAdverseEvent = 6;
                            break;
                        case 2:
                            riskOfAdverseEvent = 12;
                            break;
                        case 3:
                            riskOfAdverseEvent = 9;
                            break;
                        case 4:
                            riskOfAdverseEvent = 24;
                            break;
                        case 5:
                            riskOfAdverseEvent = 38;
                            break;
                        case 6:
                            riskOfAdverseEvent = 50;
                            break;
                        case 7:
                            riskOfAdverseEvent = 73;
                            break;
                        case 8:
                            riskOfAdverseEvent = 81;
                            break;
                        case 9:
                            riskOfAdverseEvent = 78;
                            break;
                        case 10:
                            riskOfAdverseEvent = 96;
                            break;
                        case 11:
                            riskOfAdverseEvent = 96;
                            break;
                        case 12:
                            riskOfAdverseEvent = 99;
                            break;
                        case 13:
                            riskOfAdverseEvent = 95;
                            break;
                        default:
                            riskOfAdverseEvent = 100;
                            break;
                    }


                    var Rock02 = false;
                    var Rock35 = false;
                    var RockG6 = false;
    
                    var Blat03 = false;
                    var Blat47 = false;
                    var BlatG8 = false;

                    var LabelCapColour;
                    var LabelCap;
    
                    Rock02 = (rockallScore >= 0) && (rockallScore <= 2);
                    Rock35 = (rockallScore >= 3) && (rockallScore <= 5);
                    RockG6 = (rockallScore >= 6);
    
                    Blat03 = (blatchfordScore >= 0) && (blatchfordScore <= 3);
                    Blat47 = (blatchfordScore >= 4) && (blatchfordScore <= 7);
                    BlatG8 = (blatchfordScore >= 8);
    
                    if (Rock02 && Blat03) {
                        LabelCapColour = "green";
                        LabelCap = "LOW"
                    }
    
                    if ((Rock35 && Blat03) || (RockG6 && Blat03) || (Rock02 && Blat47) || (Rock35 && Blat47) || (Rock02 && BlatG8)) {
                        LabelCapColour = "black";
                        LabelCap = "MEDIUM"
                    }
    
                    if ((Rock35 && BlatG8) || (RockG6 && Blat47) || (RockG6 && BlatG8)) {
                        LabelCapColour = "red";
                        LabelCap = "HIGH"
                    }
                    var t = document.getElementById("<%=OverallRiskLabel.ClientID%>")
                    $("#OverallScroreField").val(LabelCap);
                    $("#OverallRiskLabel").text(LabelCap);                    
                    $("#OverallRiskLabel").css("color", LabelCapColour);
                    rockallProgressBar.set_value(rockallScore);// * 10);
                    blatchfordProgressBar.set_value(blatchfordScore);// * 5);
                    rebleedProgressBar.set_value(riskBleed);// * 42/100);
                    adverseeventProgressBar.set_value(riskOfAdverseEvent);
                    mortalityProgressBar.set_value(estMortality); // * 41/100);
                };

                progressValueChanged = function progressValueChanged(sender, args) {
                    switch (sender.get_id()) {
                        case "RockallProgressBar":
                            sender.set_label(rockallScore);
                            break;
                            
                        case "BlatchfordProgressBar":
                            sender.set_label(blatchfordScore);
                            break;
                            
                        case "RebleedProgressBar":
                            sender.set_label(riskBleed + '%');
                            break;
                            
                        case "AdvertEventProgressBar":
                            sender.set_label(riskOfAdverseEvent + '%');
                            break;
                            
                        case "MortalityRadProgressBar":
                            sender.set_label(estMortality + '%');
                            break;
                    }
                };

                displayScore = function (labelId, bScore, rScore) {
                    var score = "";
                    if (bScore > -1) {
                        score = bScore;
                    }
                    if (rScore > -1) {
                        if (score !== "") {
                            score = score + "/";
                        }
                        score = score + rScore;
                    }
                    score = score + "*"
                    $("#" + labelId).text(score);
                };

                convertToInt = function (val) {
                    if (val)
                        return parseInt(val);
                    else
                        return 0;
                };

                Sys.Application.add_load(function () {
                    initialize();
                });

                global.rockallProgressBar_load = rockallProgressBar_load;
                global.blatchfordProgressBar_load = blatchfordProgressBar_load;
                global.rebleedProgressBar_load = rebleedProgressBar_load;
                global.adverseeventProgressBar_load = adverseeventProgressBar_load;
                global.mortalityProgressBar_load = mortalityProgressBar_load;
            })(window);
            function ClearControls() {
                 $('#GIBleedsTableBody').find("input:radio:checked").prop("checked",false);
                $('#GIBleedsTableBody').find('*[id*=DropDownList] input').each(function () {
                    var rID = $find($(this).attr('id').replace('_ClientState', ''));
                    var item = rID.findItemByText("");
                    if (item) { item.select(); }
                });
                var dAge = $(<%=AgeField.ClientID%>).val();
                var dGender = $(<%=GenderField.ClientID%>).val();
                var item1 = $find("<%= AgeDropDownList.ClientID%>").findItemByValue(dAge);
                if (item1) { item1.select(); }
                var fe = dGender - 1; var sk = '#GenderRadioButtonList_' + fe;
                console.log($(sk));
                $(sk).prop('checked', true);
               // $(<%= GenderRadioButtonList.ClientID%>).val(1);
                //if (item2) { item2.select(); }
                updateProgressBar();
                }
        </script>
    </telerik:RadScriptBlock>

        <telerik:RadScriptManager ID="GIBleedsRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="GIBleedsRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
       <%-- <div class="abnorHeader">Rockall and Blatchford Scores</div>--%>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="830px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="610px">

                <div id="FormDiv" runat="server">
                    <asp:HiddenField runat="server" ID="GenderField" Value="0" />
                    <asp:HiddenField runat="server" ID="AgeField" Value="0" />
                    <asp:HiddenField runat="server" ID="OverallScroreField" Value="" />
                    <div style="margin-top:10px;margin-left: 10px;margin-bottom:0px;font-size: 1em;width:778px;color:#25a0da;visibility:hidden;">
                                <b>Note: </b>
                                Age, gender and melaena fields on this screen will be automatically populated with data taken from this patients OGD endoscopic report.
                            </div>
                    <div style="margin-left:10px;">
                        <div class="rgview" id="rgGIBleeds" runat="server">
                            <br />
                            <table id="GIBleedsTable" class="rgview" width="800px">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" style="text-align: left;" colspan="2">
                                            Age
                                            <telerik:RadDropDownList ID="AgeDropDownList" runat="server" Width="100px" Skin="Windows7" Style="margin-left: 5px;margin-right:10px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                <Items>
                                                    <telerik:DropDownListItem Value="1" Text="< 60 years" />
                                                    <telerik:DropDownListItem Value="2" Text="60 - 79 years" />
                                                    <telerik:DropDownListItem Value="3" Text=">= 80 years" />
                                                </Items>
                                            </telerik:RadDropDownList>
                                            <asp:Label ID="AgeScoreLabel" runat="server" Font-Bold="true" Style="margin-right:70px;"></asp:Label>
                                            Gender
                                            <asp:RadioButtonList ID="GenderRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                <asp:ListItem Value="1" Text="Male"></asp:ListItem>
                                                <asp:ListItem Value="2" Text="Female"></asp:ListItem>
                                            </asp:RadioButtonList>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody id="GIBleedsTableBody">
                                    <tr>
                                        <td width="45%" style="border-width:0 0 0 1px;">
                                            <fieldset id="SymptomsFieldset" runat="server" style="display: block;">
                                                <legend>Symptoms</legend>
                                                <table class="tableWithNoBorders" style="width:100%">
                                                    <tr>
                                                        <td>Melaena
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="MelaenaRadioButtonList" runat="server" RepeatDirection="Horizontal" CellPadding="5" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="MelaenaScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Syncope
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="SyncopeRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="SyncopeScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>

                                            <fieldset id="ObservationFieldset" runat="server" style="display: block;">
                                                <legend>Observation (since bleed)</legend>
                                                <table class="tableWithNoBorders" style="width:100%">
                                                    <tr>
                                                        <td>Lowest Systolic BP
                                                        </td>
                                                        <td>
                                                            <telerik:RadDropDownList ID="LowestSystolicBPDropDownList" runat="server" Width="100px" Skin="Windows7" Style="margin-left: 5px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                                <Items>
                                                                    <telerik:DropDownListItem Value="0" Text="" />
                                                                    <telerik:DropDownListItem Value="1" Text="> 110" />
                                                                    <telerik:DropDownListItem Value="2" Text="100 - 109" />
                                                                    <telerik:DropDownListItem Value="3" Text="90 - 99" />
                                                                    <telerik:DropDownListItem Value="4" Text="< 90" />
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="LowestSystolicBPScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Highest pulse > 100
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="HighestPulseRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="HighestPulseScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>

                                            <fieldset id="Fieldset1" runat="server" style="display: block;">
                                                <legend>Laboratory results (since bleed)</legend>
                                                <table class="tableWithNoBorders" style="width:100%">
                                                    <tr>
                                                        <td>Urea (mmol/l)
                                                        </td>
                                                        <td>
                                                            <telerik:RadDropDownList ID="UreaDropDownList" runat="server" Width="100px" Skin="Windows7" Style="margin-left: 5px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                                <Items>
                                                                    <telerik:DropDownListItem Value="0" Text="" />
                                                                    <telerik:DropDownListItem Value="1" Text="< 6.5" />
                                                                    <telerik:DropDownListItem Value="2" Text="6.5 - 7.9" />
                                                                    <telerik:DropDownListItem Value="3" Text="8.0 - 9.9" />
                                                                    <telerik:DropDownListItem Value="4" Text="10.0 - 24.9" />
                                                                    <telerik:DropDownListItem Value="4" Text="> 25.0" />
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="UreaScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Haemoglobin (g/l)
                                                        </td>
                                                        <td>
                                                            <telerik:RadDropDownList ID="HaemoglobinDropDownList" runat="server" Width="100px" Skin="Windows7" Style="margin-left: 5px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                                <Items>
                                                                    <telerik:DropDownListItem Value="0" Text="" />
                                                                    <telerik:DropDownListItem Value="1" Text="> 129" />
                                                                    <telerik:DropDownListItem Value="2" Text="120 - 129" />
                                                                    <telerik:DropDownListItem Value="3" Text="100 - 119" />
                                                                    <telerik:DropDownListItem Value="4" Text="< 100" />
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="HaemoglobinScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                        <td rowspan="2" valign="top" style="border-width:0 1px 0 0;">
                                            <fieldset id="CoMorbiditiesFieldset" runat="server" style="display: block;">
                                                <legend>Co-morbidities (major)</legend>
                                                <table class="tableWithNoBorders" style="width:100%">
                                                    <tr>
                                                        <td>Heart failure
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="HeartFailureRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="HeartFailureScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Liver failure
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="LiverFailureRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="LiverFailureScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Renal failure
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="RenalFailureRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="RenalFailureScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Metastatic cancer
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="MetastaticCancerRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" onchange="updateProgressBar();">
                                                                <asp:ListItem Value="1" Text="No"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Yes"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="MetastaticCancerScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>

                                            <fieldset id="EndoscopyFieldset" runat="server" style="display: block;">
                                                <legend>Endoscopy</legend>
                                                <table class="tableWithNoBorders" style="width:100%">
                                                    <tr>
                                                        <td>Diagnosis (primary)
                                                            <br />
                                                            <telerik:RadDropDownList ID="DiagnosisDropDownList" runat="server" Width="350px" Skin="Windows7" Style="margin-left: 0px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                                <Items>
                                                                    <telerik:DropDownListItem Value="0" Text="" />
                                                                    <telerik:DropDownListItem Value="1" Text="None" />
                                                                    <telerik:DropDownListItem Value="2" Text="Mallory-Weiss tear, no lesion seen or SRH" />
                                                                    <telerik:DropDownListItem Value="3" Text="All other diagnoses excluding Malignancy" />
                                                                    <telerik:DropDownListItem Value="4" Text="Malignancy" />
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="DiagnosisScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Bleeding
                                                            <br />
                                                          <telerik:RadDropDownList ID="BleedingDropDownList" runat="server" Width="350px" Skin="Windows7" Style="margin-left: 0px;" Height="22px" OnClientSelectedIndexChanged="updateProgressBar">
                                                                <Items>
                                                                    <telerik:DropDownListItem Value="0" Text="" />
                                                                    <telerik:DropDownListItem Value="1" Text="None" />
                                                                    <telerik:DropDownListItem Value="2" Text="Luminal blood" />
                                                                    <telerik:DropDownListItem Value="3" Text="Adherent clot" />
                                                                    <telerik:DropDownListItem Value="4" Text="Vissible vessel" />
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td align="right">
                                                            <asp:Label ID="BleedingScoreLabel" runat="server" Font-Bold="true"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td colspan="2">
                                            <table  style="width:100%;border:none; " cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width:15%;border:none;">
                                                        <div class="ProgressBarSkinName">Rockall Score</div>
                                                    </td>
                                                    <td style="width:35%;border:none;">
                                                        <div>
                                                            <telerik:RadProgressBar RenderMode="Lightweight" ID="RockallProgressBar" runat="server" Skin="Silk"  BarType="Percent" ShowLabel="true" Value="0" Width="170px" MaxValue="25">
                                                                <ClientEvents OnLoad="rockallProgressBar_load" OnValueChanged="progressValueChanged"/>
                                                            </telerik:RadProgressBar>
                                                        </div>
                                                    </td>
                                                    <td style="width:25%;border:none;">
                                                        <div class="ProgressBarSkinName">Risk of rebleed (untreated)</div>
                                                    </td>
                                                    <td style="width:25%;border:none;">
                                                        <div class="ProgressBarUnit">
                                                            <telerik:RadProgressBar RenderMode="Lightweight" ID="RebleedProgressBar" runat="server" Skin="Silk" BarType="Percent" ShowLabel="true" Value="0" Width="170px" MaxValue="100">
                                                                <ClientEvents OnLoad="rebleedProgressBar_load" OnValueChanged="progressValueChanged"/>
                                                            </telerik:RadProgressBar>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="border:none;">
                                                        <span class="ProgressBarSkinName">Blatchford Score</span>
                                                    </td>
                                                    <td style="border:none;">
                                                        <div class="ProgressBarUnit">
                                                            <telerik:RadProgressBar RenderMode="Lightweight" ID="BlatchfordProgressBar" runat="server" Skin="Silk" BarType="Percent" ShowLabel="true" Value="0" Width="170px" MaxValue="25">
                                                                <ClientEvents OnLoad="blatchfordProgressBar_load" OnValueChanged="progressValueChanged"/>
                                                            </telerik:RadProgressBar>
                                                        </div>
                                                    </td>
                                                    <td style="border:none;">
                                                        <span class="ProgressBarSkinName">Risk of adverse event *</span>
                                                    </td>
                                                    <td style="border:none;">
                                                        <div class="ProgressBarUnit">
                                                            <telerik:RadProgressBar RenderMode="Lightweight" ID="AdvertEventProgressBar" runat="server" Skin="Silk" BarType="Percent" ShowLabel="true" Value="0" Width="170px" MaxValue="100">
                                                                <ClientEvents OnLoad="adverseeventProgressBar_load" OnValueChanged="progressValueChanged"/>
                                                            </telerik:RadProgressBar>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="4" style="border:none;">
                                                        <div class="ProgressBarUnit">
                                                            <span class="ProgressBarSkinName">Estimated inpatient mortality</span>
                                                            <telerik:RadProgressBar RenderMode="Lightweight" ID="MortalityRadProgressBar" runat="server" Skin="Sunset" BarType="Percent" ShowLabel="true" Value="0" Width="562px" MaxValue="100">
                                                                <ClientEvents OnLoad="mortalityProgressBar_load" OnValueChanged="progressValueChanged"/>
                                                            </telerik:RadProgressBar>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="4" style="border:none;text-align:right;">
                                                        * Death, rebleed blood transfusion or therapeutic intervention
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center" colspan="2">
                                            <asp:Label ID="Label1" runat="server" Font-Size="Medium" Font-Bold="true">Overall risk assessment:</asp:Label>&nbsp;&nbsp;
                                            <asp:Label ID="OverallRiskLabel" runat="server" Font-Size="Large" Font-Bold="true"></asp:Label>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
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
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Ok" Skin="Web20"  Icon-PrimaryIconCssClass="telerikOkButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicking="CloseWindow" AutoPostBack="false"  Icon-PrimaryIconCssClass="telerikCancelButton" />
                   <span style="float:right; padding-right:20px"><telerik:RadButton ID="ResetButton" runat="server" Text="Reset" OnClientClicked="ClearControls" Skin="Web20" AutoPostBack="false" Icon-PrimaryIconCssClass="rbRefresh"/></span> 
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
