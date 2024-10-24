<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/ProcedureMaster.master" CodeBehind="PostProcedure.aspx.vb" Inherits="UnisoftERS.PostProcedure" %>

<%@ Register Src="~/Procedure Modules/AdverseEvents.ascx" TagName="AdverseEvents" TagPrefix="PostProc" %>
<%@ Register Src="~/Procedure Modules/AdviceComments.ascx" TagName="AdviceComments" TagPrefix="PostProc" %>
<%@ Register Src="~/Procedure Modules/FollowUp.ascx" TagName="FollowUp" TagPrefix="PostProc" %>
<%@ Register Src="~/Procedure Modules/FurtherProcedures.ascx" TagName="FurtherProcedures" TagPrefix="PostProc" %>
<%@ Register Src="~/Procedure Modules/RX.ascx" TagName="RX" TagPrefix="PostProc" %>
<%@ Register Src="~/Procedure Modules/PathwayPlanQuestions.ascx" TagName="PathwayPlanQuestions" TagPrefix="PostProc" %>


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
            var CheckBleeding = false;
            var Id;
            var RadComboBox;
            var ComboBoxSelector;
            var bleedingothertext = ""
            var checkedQty;
            
            function checkAndNotifyTextEntry(ctrl, section) {     
                
                checkedQty = 0;
                if ($(ctrl).is(':checked')) {                  
                    //check if any other checkboxes have been ticked.
                    $('.' + section + '-parent input').not(ctrl).each(function (idx, itm) {

                        if ($(itm).is(':checked')) {
                            if ($(itm).next('label').text().trim() == "Bleeding") {
                                Id = $(this).closest('td').find('.adverseevent-parent').attr('data-adverseeventid');
                                ComboBoxSelector = '.adverseevent-child[data-adverseeventid="' + Id + '"]';
                                RadComboBox = $find($(ComboBoxSelector).attr('id'));
                                CheckBleeding = true;
                            }
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty == 0) {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            ToggleOtherTextbox(section);
                            //$('.' + section + '-free-entry-warning').show(); //display the free text entry warning message to show them we mean business -_-
                        }
                        else {
                            $(ctrl).prop('checked', false);
                            ToggleOtherTextbox(section);
                            //$('.' + section + '-other-text-entry').hide();
                        }
                    }
                    else {
                        ToggleOtherTextbox(section);
                       // $('.' + section + '-free-entry-warning').hide(); //no need to display the free text entry warning message
                    }
                }
                else {
                    ToggleOtherTextbox(section);
                    //clear text box
                    //$('.' + section + '-additional-info').val('');
                }
            }

            function OtherBoxShow() {
                    var label = $('.checkValues').find('.indications-parent');
                    var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                    var warning = $('.checkValues').find('.adverseevent-free-entry-warning');
                    
                    label.each(function (labelIdx, labelItem) {
                        var labelValue = $(labelItem).text();
                        if (labelValue === "Other" || labelValue === "Other complication") { //could minimize 
                            $(labelItem).show();
                            $(radTextBoxes[labelIdx]).show();
                            $(warning[labelIdx]).show();
                            var escapedLabelValue = labelValue.replace(/ /g, '\\ ');
                            $('#OtherBoxTD_' + escapedLabelValue).css('display', 'table-cell');                                                         
                        }
                    });
            }

            function OtherBoxHide() {
                    var label = $('.checkValues').find('.indications-parent');
                    var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                    var warning = $('.checkValues').find('.adverseevent-free-entry-warning');                
                    label.each(function (labelIdx, labelItem) {
                        var labelValue = $(labelItem).text();
                        if (labelValue === "Other" || labelValue === "Other complication") { //could minimize 
                            $(labelItem).hide();
                            $(radTextBoxes[labelIdx]).hide();
                            $(radTextBoxes[labelIdx]).val('');
                            $(warning[labelIdx]).hide();
                            var escapedLabelValue = labelValue.replace(/ /g, '\\ ');
                            $('#OtherBoxTD_' + escapedLabelValue).css('display', 'none');                           
                        }
                    });
            }

            function OtherBleedingBoxShow() {
                    var label = $('.checkValues').find('.indications-parent');
                    var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                    var warning = $('.checkValues').find('.adverseevent-free-entry-warning');
                    label.each(function (labelIdx, labelItem) {
                        var labelValue = $(labelItem).text();
                        if (labelValue === "Other Bleeding Text") {
                            $(labelItem).show();
                            $(radTextBoxes[labelIdx]).show();
                            $(warning[labelIdx]).show();
                            var escapedLabelValue = labelValue.replace(/ /g, '\\ ');
                            $('#OtherBoxTD_' + escapedLabelValue).css('display', 'table-cell');                           
                        }
                    });
                
            }

            function OtherBleedingBoxHide() {
                var additionalInfoText;
                    var label = $('.checkValues').find('.indications-parent');
                    var radTextBoxes = $('.checkValues').find('.adverseevent-additional-info');
                    var warning = $('.checkValues').find('.adverseevent-free-entry-warning');
                    label.each(function (labelIdx, labelItem) {
                        var labelValue = $(labelItem).text();
                        if (labelValue === "Other Bleeding Text") {
                            $(labelItem).hide();
                            $(radTextBoxes[labelIdx]).hide();
                            $(radTextBoxes[labelIdx]).val('');
                            $(warning[labelIdx]).hide();   
                            var escapedLabelValue = labelValue.replace(/ /g, '\\ ');
                            $('#OtherBoxTD_' + escapedLabelValue).css('display', 'none');     
                        }
                    });
                saveAdverseEvent(otherBleedingUniqueId, 0, false, '');
            }

            function ToggleOtherTextbox(section) {
               
                $('.' + section + '-other-entry-toggle input').each(function (idx, itm) {
                    
                    if ($(this).is(':checked')) {

                        OtherBoxShow();
                        
                        if (CheckBleeding) { // other checked + bleeding checked 
                            $('.adverseevent-child').each(function () {
                                if (RadComboBox) {
                                    var SelectedText = RadComboBox.get_selectedItem()?.get_text() || '';                          
                                    if (SelectedText === "Other") {
                                        OtherBleedingBoxShow();
                                    }
                                    else {
                                        OtherBleedingBoxHide(); 
                                    }
                                }
                            });
                        }                        
                    }
                    else {
                        //$('.' + section + '-other-text-entry').hide();
                        OtherBoxHide();
                        if (CheckBleeding) { // other unchecked + bleeding checked 
                            $('.adverseevent-child').each(function () {

                                if (RadComboBox) {
                                    var SelectedText = RadComboBox.get_selectedItem()?.get_text() || '';
                                    if (SelectedText === "Other") {
                                        OtherBleedingBoxShow(); 
                                    }
                                    else {
                                        OtherBleedingBoxHide();
                                    }
                                }
                            });
                        }
                        
                    }
                });
              
                $('.adverseevent-parent input:checkbox').each(function () {
                   
                   if ($(this).closest('td').find('.adverseevent-parent').text() === "Bleeding" && $(this).prop('checked')) {  
                       var id = $(this).closest('td').find('.adverseevent-parent').attr('data-adverseeventid');
                       comboBoxSelector = '.adverseevent-child[data-adverseeventid="' + id + '"]';
                       radComboBox = $find($(comboBoxSelector).attr('id'));
                       $('.adverseevent-child').each(function () {
                           if (radComboBox) {
                               var SelectedText = radComboBox.get_selectedItem()?.get_text() || '';
                               if (SelectedText === "Other") {
                                   OtherBleedingBoxShow();
                               } else {
                                   OtherBleedingBoxHide();
                               }
                           }
                       });
                   }     

                   if ($(this).closest('td').find('.adverseevent-parent').text() === "Bleeding" && !$(this).prop('checked')) {
                       OtherBleedingBoxHide();
                   }
               });
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
                newProcedureInitiated = true;
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
            <div style="float: left">
                <asp:Label ID="ProcedureTypeLabel" runat="server" Text="Post procedure" Font-Bold="true" />
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
                <div>
                    <div style="margin-top: 10px;">
                    </div>
                    <div class="procedure-control" runat="server" id="adverseevents" tabindex="-1" clientidmode="Static">
                        <PostProc:AdverseEvents ID="PostProcAdverseEvents" runat="server" />
                    </div>


                    <div class="procedure-control" id="rxId" tabindex="-1">
                        <div class="control-section-header abnorHeader">RX</div>
                        <PostProc:RX ID="PostProcRX" runat="server" />
                    </div>

                    <div class="procedure-control">
                        <div class="control-section-header abnorHeader">Advice and comments</div>
                        <PostProc:AdviceComments ID="PostProcAdviceComments" runat="server" />
                    </div>

                    <div class="procedure-control">
                        <PostProc:PathwayPlanQuestions ID="PostProcPathwayPlanQuestions" runat="server" />
                    </div>

                    <div class="procedure-control" id="followUpId" tabindex="-1">
                        <div class="control-section-header abnorHeader">Follow up&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
                        <PostProc:FollowUp ID="PostProcFollowUp" runat="server" />
                    </div>

                    <div class="procedure-control">
                        <div class="control-section-header abnorHeader">Further procedures</div>
                        <PostProc:FurtherProcedures ID="PostProcFurtherProcedures" runat="server" />
                    </div>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </div>
</asp:Content>
