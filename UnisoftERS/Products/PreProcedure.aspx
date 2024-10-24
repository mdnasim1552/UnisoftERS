<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/ProcedureMaster.master" CodeBehind="PreProcedure.aspx.vb" Inherits="UnisoftERS.preprocedure_aspx" %>

<%@ Register Src="~/Procedure Modules/Indications.ascx" TagName="Indications" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/CoMorbidity.ascx" TagName="CoMorbidity" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/DamagingDrugs.ascx" TagName="DamagingDrugs" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Allergies.ascx" TagName="Allergies" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/PreviousSurgery.ascx" TagName="PreviousSurgery" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/PreviousDiseases.ascx" TagName="PreviousDiseases" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/FamilyHistory.ascx" TagName="FamilyHistory" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Imaging.ascx" TagName="Imaging" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/ASAStatus.ascx" TagName="ASAStatus" TagPrefix="PreProc" %>
<%--<%@ Register Src="~/Procedure Modules/ProcedureDrugs.ascx" TagName="ProcedureDrugs" TagPrefix="PreProc" %>--%>
<%--<%@ Register Src="~/Procedure Modules/BowelPrep.ascx" TagName="ProcedureBowelPrep" TagPrefix="PreProc" %>--%>
<%@ Register Src="~/Procedure Modules/LUTSIPSSSymptomscore.ascx" TagName="LUTSIPSSSymptomscore" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/PreviousDiseasesUrology.ascx" TagName="PreviousDiseasesUrology" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/UrineDipstickCytology.ascx" TagName="UrineDipstickCytology" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Smoking.ascx" TagName="Smoking" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Alcohol.ascx" TagName="Alcohol" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/CystoscopyHeader.ascx" TagName="CystoscopyHeader" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Ebus.ascx" TagName="Ebus" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/Staging.ascx" TagName="Staging" TagPrefix="PreProc" %>
<%@ Register Src="~/Procedure Modules/FITResult.ascx" TagName="FITValueResult" TagPrefix="PreProc" %>
<%@ Register TagPrefix="PreProc" TagName="ReferralData" Src="~/Procedure Modules/ReferralData.ascx" %>
<%--<%@ Register TagPrefix="PreProc" TagName="DrugsAdministered" Src="~/Procedure Modules/DrugsAdministered.ascx" %>--%>

<asp:Content ID="Content1" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="server">
    <style type="text/css">
        .control-sub-header {
            margin-top: 3px;
            margin-left: 15px;
            font-size: 16px;
            border-bottom: 1px dashed silver;
        }

        .control-content {
            padding: 15px;
        }

        .section-table tr td:first-child {
            padding-right: 10px;
            width: 150px;
            vertical-align: top;
        }
        #asastatus
        {
            margin-top: 25px !important;
        }

        .highlight-border {
            border: 2px solid red; /* Or any color you prefer */
            transition: border 0.3s ease; /* Smooth transition */
        }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function focusOnDiv(id) {
                const highlightClass = 'highlight-border';

                // Add the class to the div
                $(id).addClass(highlightClass);

                $('html, body').animate({
                    scrollTop: $(id).offset().top
                }, 'slow', function () {
                    $(id).focus();
                    // Optionally, you can also remove the highlight class after some time
                    setTimeout(function () {
                        $(id).removeClass(highlightClass);
                    }, 5000); // Remove after 2 seconds or adjust as needed
                });
            }

            function closeDialogImagePort() {
                $find("<%=ImagesExistRadWindow.ClientID%>").close();
            }

            function checkAndNotifyTextEntry(ctrl, section) {
                var checkedQty = 0;

                if ($(ctrl).is(':checked')) {
                    //check if any other checkboxes have been ticked.
                    $('.' + section + '-parent input').not(ctrl).each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });

                    if (checkedQty == 0) {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            ToggleOtherTextbox(section);
                            $('.' + section + '-free-entry-warning').show(); //display the free text entry warning message to show them we mean business -_-
                        }
                        else {
                            $(ctrl).prop('checked', false);
                            ToggleOtherTextbox(section);
                            $('.' + section + '-other-text-entry').hide();
                        }
                    }
                    else {
                        ToggleOtherTextbox(section);
                        $('.' + section + '-free-entry-warning').hide(); //no need to display the free text entry warning message
                    }
                }
                else {
                    ToggleOtherTextbox(section);
                    //clear text box
                    $('.' + section + '-additional-info').val('');
                }
            }

            function ToggleOtherTextbox(section) {
                $('.' + section + '-other-entry-toggle input').each(function (idx, itm) {
                    if ($(this).is(':checked')) {
                        $('.' + section + '-other-text-entry').show();
                    }
                    else {
                        $('.' + section + '-other-text-entry').hide();


                    }
                });
            }

            function showFolderViewer() {
                var ua = window.navigator.userAgent;
                var msie = ua.indexOf("MSIE ");
                // showModalDialog is deprecated and only works in IE
                if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) // If Internet Explorer, show modal window
                {
                    window.showModalDialog('Common/FolderView.aspx', 'ImagePort Viewer', 'resizable,scrollbars,height=375,width=665');
                }
                else  // If another browser, show window
                {
                    window.open('Common/FolderView.aspx', 'ImagePort Viewer', 'resizable,scrollbars,height=375,width=665');
                }

                return false;
            }
        </script>
    </telerik:RadScriptBlock>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="server">
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            $(document).ready(function () {
                var isChecked = $('#<%= ProcNotCarriedOutCheckBox.ClientID %>').is(':checked');
                if (isChecked)
                    enableDisableProcedureButton(isChecked);

                setRehideSummary();
                if (summaryState == 'collapsed') {
                    hideShowSummary(false);
                }
                else {
                    hideShowSummary(true);
                }

                $("#<%=ProcNotCarriedOutCheckBox.ClientID%>").on('click', function (e) {
                    var isChecked = $(this).is(":checked");
                    if (isChecked) {
                        e.preventDefault();
                    }
                    showProcNotCarriedOutWindow(isChecked);
                    hideShowSummary(false);
                });
            });
        </script>
    </telerik:RadScriptBlock>
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <div id="ContentDiv">
        <div class="otherDataHeading" ondblclick="DisplayProcedureInfo()">
             <%--icon removed by ferdowsi, TFS -4436--%>
            <div style="float: left">
                <asp:Label ID="ProcedureTypeLabel" runat="server" Text="Pre procedure" Font-Bold="true" />
            </div>


            <div id="divRequirementsKey" runat="server" style="float: right; font-size: small; text-align: right;">
                <img src="../Images/NEDJAG/Mand.png" />Mandatory&nbsp;&nbsp;<img src="../Images/NEDJAG/NED.png" />National Data Set Requirement&nbsp;&nbsp;<img src="../Images/NEDJAG/JAG.png" />JAG Requirement
            </div>
            <div style="float: left; padding: 3px 5px;">
                <div>
                    <asp:CheckBox ID="ProcNotCarriedOutCheckBox" CssClass="cancelled-proc-cb" runat="server" Text="Procedure not carried out" AutoPostBack="false" />
                </div>
            </div>
        </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" CssClass="preOrPostProcedureWithoutSummary">
                <div runat="server" id="CystoscopyHeaderDiv" visible="false">
                    <PreProc:CystoscopyHeader ID="PreProcCystoscopyHeader" runat="server" />
                </div>
                <div id="imaging">
                    <PreProc:Imaging ID="PreProcImaging" runat="server" />
                </div>
                <div class="procedure-control" id="fitValueResults" runat="server" tabindex="-1" clientidmode="Static">
                    <PreProc:FITValueResult ID="PreProcFitValueResults" runat="server" />
                </div>
                <div class="procedure-control" id="indications" tabindex="-1">
                    <PreProc:Indications ID="PreProcIndications" runat="server" />
                </div>
                <div>
                    <PreProc:FamilyHistory ID="PreProcFamilyHistory" runat="server" />
                </div>

                <div runat="server" id="StagingDiv">
                    <PreProc:Staging ID="PreStaging" runat="server" />
                </div>

                <div runat="server" id="LUTSIPSSSymptomsDiv">
                    <PreProc:LUTSIPSSSymptomscore ID="LUTSIPSSSymptomscore" runat="server" />
                </div>

                    <div runat="server" id="SmokingDiv">
                        <PreProc:Smoking ID="Smoking" runat="server" />
                    </div>   
                
                    <div runat="server" id="AlcoholDiv">
                        <PreProc:Alcohol ID="Alcohol" runat="server" />
                    </div>

                     <div runat="server" id="comorbidity">
                        <PreProc:CoMorbidity ID="PreProcCoMorbidity" runat="server" />
                    </div>  

                <div runat="server" id="UrineDipstickCytologyDiv">
                    <PreProc:UrineDipstickCytology ID="UrineDipstickCytology" runat="server" />
                </div>

                <div id="asastatus">
                    <PreProc:ASAStatus ID="PreProcASAStatus" runat="server" />
                </div>

                <div id="anticoagdrugs" tabindex="-1">
                    <PreProc:DamagingDrugs ID="PreProcDamagingDrugs" runat="server" />
                </div>

                <div id="allergies">
                    <PreProc:Allergies ID="PreProcAllergies" runat="server" />
                </div>

                <div runat="server" id="PreviousHistoryUrologyDiv">
                    <PreProc:PreviousDiseasesUrology ID="PreviousDiseasesUrology" runat="server" />
                </div>

                <div runat="server" id="PreviousHistoryDiv">
                    <div class="abnorHeader">Previous History</div>
                    <PreProc:PreviousDiseases ID="PreProcPreviousDiseases" runat="server" />
                    <PreProc:PreviousSurgery ID="PreProcPreviousSurgery" runat="server" />
                </div>

                <div runat="server" id="EbusControl">

                    <PreProc:ReferralData ID="PreProcReferralData" runat="server" Visible="false" />
                </div>

                <%--<div runat="server">  MH commented out on 05 Feb 2024 TFS 3010
                        <div class="abnorHeader">Drugs&nbsp;<img src="../Images/NEDJAG/JAGNED.png" alt="JAGNED Mandatory Field" /></div>

                        <div id="bowelprep">
                            <PreProc:ProcedureBowelPrep ID="ProcBowelPrep" runat="Server" />
                        </div>
                        <div id="proceduredrugs">
                            <PreProc:ProcedureDrugs ID="ProcDrugsAdministered" runat="Server" />
                        </div>
                        <div id="broncsdrugs">
                            <PreProc:DrugsAdministered ID="PreProcDrugsAdministered" runat="server" Visible="false" />
                        </div>
                    </div>  --%>
            </telerik:RadPane>
            <%-- <telerik:RadPane ID="EbusControlsRadPane" runat="server">
                <div>
                    <div style="margin-top: 10px;">
                    </div>


                </div>

            </telerik:RadPane>--%>
        </telerik:RadSplitter>

    </div>
    <telerik:RadWindowManager ID="PatientProcedureRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="ImagesExistRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="250px" VisibleStatusbar="false" VisibleOnPageLoad="false" Visible="false" Title="ImagePort Images" BackColor="#ffffcc">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                <img id="Img2" runat="server" src="~/Images/info-32x32.png" />
                            </td>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblImageExistsMessage" runat="server" Font-Size="Large" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="padding: 10px; text-align: center;">
                                <telerik:RadButton ID="RemoveImages" runat="server" Text="Yes" Skin="Windows7" ButtonType="SkinnedButton" OnClientClicked="closeDialogImagePort" Width="100" Height="30" Font-Size="Large" />
                                <telerik:RadButton ID="KeepImages" runat="server" AutoPostBack="false" Text="No" Skin="Windows7" ButtonType="SkinnedButton" OnClientClicked="closeDialogImagePort" Width="100" Height="30" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>
</asp:Content>
