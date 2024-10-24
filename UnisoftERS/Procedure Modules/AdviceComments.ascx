<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="AdviceComments.ascx.vb" Inherits="UnisoftERS.AdviceComments" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        function displayPatientInformedDetails() {
            var selectedValue = $("#<%= chkPatientInformed.ClientID%>").is(':checked');
            if (selectedValue) {
                $("#ReasonWhyNotInformedTextBox").hide();
            }
            else {
                $("#ReasonWhyNotInformedTextBox").show();
            }

            saveAdviceAndComments();
        }

        $(window).on('load', function () {
            displayCancerEvidenceDetails();
        });

        $(document).ready(function () {
            $('#<%= rblCancerEvidence.ClientID %> input').change(function () {
                displayCancerEvidenceDetails();
                saveAdviceAndComments();
            });

            $('.advice-comments-text-input').on('focusout', function () {
                saveAdviceAndComments();
            });

            $('.advice-comments-check-box').on('change', function () {
                saveAdviceAndComments();
            });

            $('#<%=WhoPerformanceStatusTextBox.ClientID%>').on('click', function () {
                ToggleUrgentDiv(true);
            });
        });

        function displayCancerEvidenceDetails() {
            var cancerEvidenceResponseSelected = $('#<%= rblCancerEvidence.ClientID %> input:checked').val();
            var patientInformedSelected = $("#<%= chkPatientInformed.ClientID%>").is(':checked');
            if (cancerEvidenceResponseSelected == 1 || cancerEvidenceResponseSelected == 2) {
                $("#PatientInformedDetails").show();
                if (patientInformedSelected == false) {
                    $("#ReasonWhyNotInformedTextBox").show();
                }
                else {
                    $("#ReasonWhyNotInformedTextBox").hide();
                }

                $("#FastTrackRemovedDetails").show();
                $("#CnsMdtcInformedDetails").show();

                //not detected tr
                if (cancerEvidenceResponseSelected == 2) {
                    $("#NotDetected").show();
                }
                else {
                    $("#NotDetected").hide();
                }
            } else if (cancerEvidenceResponseSelected == 3) {
                $("#PatientInformedDetails").hide();
                $("#ReasonWhyNotInformedTextBox").hide();
                $("#FastTrackRemovedDetails").hide();
                $("#CnsMdtcInformedDetails").hide();
                $("#NotDetected").hide();
            }
            if (cancerEvidenceResponseSelected == 1 || cancerEvidenceResponseSelected == 3) {
                $("#FastTrackRemovedDetails").hide();
            }
            else {
                $("#FastTrackRemovedDetails").show();
            }
        }

        function CalledAdviceCommentsFn(data, ops) {
            if (ops == 'CommentRep') {
                $find("<%= CommentsTextBox.ClientID%>").set_value(data);
            } else if (ops == 'FriendlyRep') {
                $find("<%= PfrFollowUpTextBox.ClientID%>").set_value(data);
            }
            saveAdviceAndComments();
        }

        function showLibraryAdviceComments(details) {
            if (details == 'CommentRep') {
                var btn = $find("<%= CommentsTextBox.ClientID%>");
                var win = radopen("../Products/Common/WordLibrary.aspx?option=CommentRep&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(AdviceTab);
            } else if (details == 'FriendlyRep') {
                var btn = $find("<%= PfrFollowUpTextBox.ClientID%>");
                var win = radopen("../Products/Common/WordLibrary.aspx?option=FriendlyRep&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(AdviceTab);
            }
        }

        function displayReBleedOther() {
            var reBleedPlanOtherResponseSelected = $('#<%= ReBleedPlanOtherCheckBox.ClientID %>').is(':checked');

            if (reBleedPlanOtherResponseSelected) {
                $('.ReBleedPlanOtherOptionTRClass').show();
            }
            else {
                $('.ReBleedPlanOtherOptionTRClass').hide();
                $('#<%= ReBleedPlanOtherOptionTextBox.ClientID %>').val('');
            }
        }

        function saveAdviceAndComments() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureTypeId = parseInt(<%= procType %>);
            obj.evidenceOfCancer = ($('#<%= rblCancerEvidence.ClientID %> input:checked').length > 0) ? parseInt($('#<%= rblCancerEvidence.ClientID %> input:checked').val()) : -1;
            obj.patientInformed = $("#<%= chkPatientInformed.ClientID%>").is(':checked');
            obj.patientNotInformedReason = $find("<%= txtReasonWhyNotInformed.ClientID%>").get_value();
            obj.removedFromFastTrack = $("#<%= chkFastTrackRemoved.ClientID%>").is(':checked');
            obj.CNSInformed = $("#<%= chkCnsMdtcInformed.ClientID%>").is(':checked');
            obj.repeatGastroscopy = $("#<%= ReBleedPlanRepeatGastroCheckBox.ClientID%>").is(':checked');
            obj.requestSurgicalReview = $("#<%= ReBleedPlanReqSurgRevCheckBox.ClientID%>").is(':checked');
            obj.otherRebleedPlanText = ($('#<%= ReBleedPlanOtherOptionTextBox.ClientID %>').length > 0) ? $('#<%= ReBleedPlanOtherOptionTextBox.ClientID %>').val() : '';
            obj.comments = $find("<%= CommentsTextBox.ClientID%>").get_textBoxValue();
            obj.urgentTwoWeekReferral = $("#<%= UrgentTwoWeekCheckBox.ClientID%>").is(':checked');
            obj.findingAlert = $("#<%= chkFindingAlert.ClientID%>").is(':checked');
            obj.imagingRequested = $("#<%= chkImagingRequested.ClientID%>").is(':checked');
            obj.cancerResultId = parseInt($find("<%= CancerComboBox.ClientID%>").get_selectedItem().get_value());
            obj.whoStatusId = ($find("<%= WhoPerformanceStatusTextBox.ClientID%>").get_value() == '') ? 0 : parseInt($find("<%= WhoPerformanceStatusTextBox.ClientID%>").get_value());
            obj.followUpText = $find("<%= PfrFollowUpTextBox.ClientID%>").get_textBoxValue();
            obj.cancerNotDetected = $("#<%= chkNotDetected.ClientID%>").is(':checked');

            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveAdviceAndComments",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

        //### Urgent two week referral
        function ToggleUrgentDiv(showPopup) {
            //console.log("Called from: ToggleUrgentDiv(showPopup)");
            if ($("#<%= UrgentTwoWeekCheckBox.ClientID%>").is(':checked')) {
                $find("<%=CancerComboBox.ClientID%>").enable();
                $("#<%= UrgentDiv.ClientID%>").show();
                if (showPopup) {
                    var oWnd = $find("<%= WHOStatusPickerWindow.ClientID%>");
                    oWnd.show();
                }
            }
            else {
                var combo = $find("<%=CancerComboBox.ClientID%>");
                combo.disable();
                combo.set_text("");
                $("#<%= UrgentDiv.ClientID%>").hide();
                ClearControls($("#<%= UrgentDiv.ClientID%>"));
                $("#<%= WHOStatusRadioButtonList.ClientID%> input:radio:checked").removeAttr("checked");
            }
        }

        function SetWhoStatus() {
            $find("<%= WhoPerformanceStatusTextBox.ClientID%>").set_value($("#<%= WHOStatusRadioButtonList.ClientID%> input:checked").val());
            CloseWhoStatusPickerWindow();

            saveAdviceAndComments();
        }

        function CloseWhoStatusPickerWindow() {
            var oWnd = $find("<%= WHOStatusPickerWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

<div class="control-content">
    <%-- Pathway plan
    <asp:Repeater ID="FollowUpQuestionsRepeater" runat="server" OnItemDataBound="FollowUpQuestionsRepeater_ItemDataBound">
        <HeaderTemplate>
            <table class="DataBoundTable">
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td>
                    <asp:HiddenField ID="QuestionIdHiddenField" runat="server" Value='<%#Eval("QuestionId") %>' />
                    <asp:Image ID="QuestionMandatoryImage" runat="server" ImageUrl="../Images/NEDJAG/Mand.png" AlternateText="Mandatory Field" />
                    <span><%#Eval("Question") %></span></td>
                <td>
                    <asp:RadioButtonList ID="QuestionOptionRadioButton" runat="server" RepeatDirection="Horizontal" CssClass="cancer-question-option" data-itemid='<%#Eval("QuestionId") %>'>
                        <asp:ListItem Text="Yes" Value="1" />
                        <asp:ListItem Text="No" Value="0" />
                    </asp:RadioButtonList>
                    <telerik:RadTextBox ID="QuestionAnswerTextBox" runat="server" Skin="Metro" CssClass="cancer-question-input" data-itemid='<%#Eval("QuestionId") %>' />
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>--%>

    <table class="rptSummaryText10" cellpadding="3" cellspacing="3" style="display: none;">
        <tr>
            <td>
                 <label>Evidence of cancer:</label>
                <asp:RadioButtonList ID="rblCancerEvidence" runat="server" onclick="displayCancerEvidenceDetails();"
                    CellSpacing="35" CellPadding="5" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                    <asp:ListItem Value="1" Text="Yes" style="margin-right: 15px;"></asp:ListItem>
                    <asp:ListItem Value="2" Text="No" style="margin-right: 15px;"></asp:ListItem>
                    <asp:ListItem Value="3" Text="Unknown" style="margin-right: 15px;"></asp:ListItem>
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr id="NotDetected">
            <td>
                <asp:CheckBox ID="chkNotDetected" runat="server" Text="No cancer detected during this procedure" CssClass="advice-comments-check-box" />
            </td>
        </tr>
        <tr id="PatientInformedDetails">
            <td>
                <asp:CheckBox ID="chkPatientInformed" runat="server" Text="Patient informed" onchange="displayPatientInformedDetails();" />
            </td>
        </tr>
        <tr id="ReasonWhyNotInformedTextBox">
            <td>&nbsp; &nbsp;
                <telerik:RadTextBox ID="txtReasonWhyNotInformed" CssClass="advice-comments-text-input" runat="server" Skin="Windows7" TextMode="SingleLine"
                    EmptyMessage="Reason why patient is not informed" Width="482" Height="20" />
            </td>
        </tr>
        <tr id="FastTrackRemovedDetails">
            <td>
                <asp:CheckBox ID="chkFastTrackRemoved" runat="server" Text="Patient removed from fast track" CssClass="advice-comments-check-box" />
            </td>
        </tr>
        <tr id="CnsMdtcInformedDetails">
            <td>
                <asp:CheckBox ID="chkCnsMdtcInformed" runat="server" Text="CNS/MDTC informed" CssClass="advice-comments-check-box" />
            </td>
        </tr>
        <tr id="ImagingRequested">
            <td>
                <asp:CheckBox ID="chkImagingRequested" runat="server" Text="Imaging has been requested" CssClass="advice-comments-check-box" />
            </td>
        </tr>
        
        <tr>
            <td>
                <asp:CheckBox ID="UrgentTwoWeekCheckBox" runat="server"
                    Text="Urgent two week referral"
                    onchange="ToggleUrgentDiv(true);" CssClass="UrgentCheckBox advice-comments-check-box" />


                <div style="margin-left: 10px; margin-bottom: 3px;">
                    Cancer&nbsp;&nbsp;
                        <telerik:RadComboBox ID="CancerComboBox" runat="server" Width="100" Skin="Windows7" OnClientSelectedIndexChanged="saveAdviceAndComments">
                            <Items>
                                <telerik:RadComboBoxItem Text="" Value="0" />
                                <telerik:RadComboBoxItem Text="Definite" Value="1" />
                                <telerik:RadComboBoxItem Text="Suspected" Value="2" />
                                <telerik:RadComboBoxItem Text="Excluded" Value="3" />
                            </Items>
                        </telerik:RadComboBox>
                </div>
                <div id="UrgentDiv" runat="server" style="margin-left: 10px;">
                    WHO Performance Status&nbsp;&nbsp;
                    <telerik:RadTextBox ID="WhoPerformanceStatusTextBox" runat="server" Skin="Windows7" Width="30" CssClass="advice-comments-text-input" />
                </div>
            </td>
        </tr>
    </table>
    <table>
        <tr id="ClinicalFindingAlert">
            <td>
                <asp:CheckBox ID="chkFindingAlert" runat="server" Text="Clinical findings alert" CssClass="advice-comments-check-box" />
            </td>
        </tr>
    </table>
    <br />
    <div id="ReBleedPlanDiv" runat="server">
        <table id="ReBleedPlanTable" class="reBleedPlan">
            <tr>
                <td>
                    <label>RE-Bleed plan:</label>
                    <asp:CheckBox ID="ReBleedPlanRepeatGastroCheckBox" runat="server" Text="Repeat gastroscopy" CssClass="advice-comments-check-box"></asp:CheckBox>
                    <asp:CheckBox ID="ReBleedPlanReqSurgRevCheckBox" runat="server" Text="Request surgical review" CssClass="advice-comments-check-box"></asp:CheckBox>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:CheckBox ID="ReBleedPlanOtherCheckBox" runat="server" Text="Other (please specify)" onclick="displayReBleedOther()" />
                    <%--onchange="ToggleReviewDetails('ReBleedPlanOtherOptionTR');" />--%>
                </td>
            </tr>
            <tr id="ReBleedPlanOtherOptionTR" class="ReBleedPlanOtherOptionTRClass">
                <td>
                    <asp:TextBox ID="ReBleedPlanOtherOptionTextBox" class="ReBleedPlanOtherOptionClass advice-comments-text-input" runat="server" Visible="true"></asp:TextBox>
                </td>
            </tr>
        </table>
    </div>
    <br />
    <table class="rptSummaryText10">
        <tr>
            <td>Printed at the end of the report</td>
        </tr>
        <tr>
            <td>
                <telerik:RadTextBox ID="CommentsTextBox" CssClass="advice-comments-text-input" runat="server" Skin="Windows7" TextMode="MultiLine"
                    Width="1000" Height="96"  MaxLength="1000" /><img src="../Images/phrase_library.png" style="padding-left: 5px"
                        onclick="showLibraryAdviceComments('CommentRep');return false;" title="Phrases" />
            </td>
        </tr>
        <tr>
            <td style="height: 10px;"></td>
        </tr>
        <tr>
            <td>To be included in the patient friendly report</td>
        </tr>
        <tr>
            <td>
                <telerik:RadTextBox ID="PfrFollowUpTextBox" CssClass="advice-comments-text-input" runat="server" Skin="Windows7" TextMode="MultiLine"
                    Width="1000" Height="96" MaxLength="1000"  /><img src="../Images/phrase_library.png" style="padding-left: 5px"
                        onclick="javascript:showLibraryAdviceComments('FriendlyRep');return false;" title="Phrases" />
            </td>
        </tr>
    </table>
</div>
<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False"
    Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
    <Windows>
        <telerik:RadWindow ID="WHOStatusPickerWindow" runat="server" ReloadOnShow="true"
            KeepInScreenBounds="true" Width="700px" Height="230px" Title="WHO Performance Status" VisibleStatusbar="false" Animation="Fade">
            <ContentTemplate>
                <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                    <asp:RadioButtonList ID="WHOStatusRadioButtonList" runat="server"
                        CellSpacing="1" CellPadding="1" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="whoRadioList"
                        onchange="SetWhoStatus();">
                        <asp:ListItem Value="0" Text="<b>0</b> - Fully active, no restrictions on activities"></asp:ListItem>
                        <asp:ListItem Value="1" Text="<b>1</b> - Unable to do strenuous activities, but able to carry out light housework and sedentary activities"></asp:ListItem>
                        <asp:ListItem Value="2" Text="<b>2</b> - Able to walk and manage self-care, but unable to work. Out of bed more than 50% of waking hours"></asp:ListItem>
                        <asp:ListItem Value="3" Text="<b>3</b> - Confined to bed or a chair more than 50% of waking hours. Capable of limited self-cares"></asp:ListItem>
                        <asp:ListItem Value="4" Text="<b>4</b> - Completely disabled. Totally confined to a bed or chair. Unable to do any self-care"></asp:ListItem>
                        <%--<asp:ListItem Value="5" Text="<b>5</b> - Death"></asp:ListItem>--%>
                    </asp:RadioButtonList>
                </div>
                <div id="buttonsdiv" style="margin-left: 5px; height: 10px; padding-top: 16px; vertical-align: central;">
                    <telerik:RadButton ID="CloseWhoPickerButton" runat="server" Text="Close" Skin="WebBlue"
                        OnClientClicked="CloseWhoStatusPickerWindow" AutoPostBack="false" />
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
