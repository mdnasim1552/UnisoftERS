<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PathwayPlanQuestions.ascx.vb" Inherits="UnisoftERS.PathwayPlanQuestions" %>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('input[name$="QuestionOptionRadioButton"]').change(function () {
                var selectedValue = $(this).val();
                var comboBox = getComboBoxId(this);
                if (comboBox != null && comboBox.get_element) {
                    $(comboBox.get_element()).show();
                    comboBox.clearSelection();
                    $.ajax({
                        type: "POST",
                        url: "PostProcedure.aspx/GetEvidenceOfCancer",
                        data: JSON.stringify({ optionAnswer: selectedValue }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var items = JSON.parse(response.d);

                            comboBox.get_items().clear();
                            var emptyItem = new Telerik.Web.UI.RadComboBoxItem();
                            emptyItem.set_text("");
                            emptyItem.set_value(0);
                            comboBox.get_items().add(emptyItem);

                            for (var key in items) {
                                if (items.hasOwnProperty(key)) {
                                    var manipulatedKey = key;
                                    var manipulatedValue = items[key];
                                    var item = new Telerik.Web.UI.RadComboBoxItem();
                                    item.set_text(manipulatedValue);
                                    item.set_value(manipulatedKey);
                                    comboBox.get_items().add(item);
                                }
                            }
                        },
                        failure: function (response) {

                        }
                    });
                }

            });

            $('.cancer-question-option').on('change', function () {
                var questionId = $(this).attr('data-itemid');
                var optionAnswer = $(this).find('input:checked').val();
                var textAnswer = ($(this).closest('tr').find('.cancer-question-input') == null) ? '' : $(this).closest('tr').find('.cancer-question-input').val();

                saveCancerQuestions(questionId, optionAnswer, textAnswer);
            });

            $('.cancer-question-input').on('focusout', function () {
                var questionId = $(this).attr('data-itemid');
                var optionAnswer = $(this).closest('tr').find('.cancer-question-option input:checked').val();
                var textAnswer = $(this).val();

                saveCancerQuestions(questionId, optionAnswer, textAnswer);
            });

            $('#<%=WhoPerformanceStatusTextBox.ClientID%>').on('click', function () {
                ToggleUrgentDiv(true);
            });

        });

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

        function getComboBoxId(element) {
            var repeaterItem = $(element).closest("tr");
            var comboBoxElement = repeaterItem.find(".cancer-question-combobox");
            var comboBox = $find(comboBoxElement.attr("id"));
            return comboBox;
        }

        function getComboboxSelectedItem(sender, args) {
            var selectedItem = args.get_item();
            var itemId = selectedItem.get_value();

            var questionId = sender.get_attributes().getAttribute("data-questionid");
            var optionAnswer = $(sender.get_element()).closest('tr').find('.cancer-question-option input:checked').val();
            var textAnswer = $(sender.get_element()).closest('tr').find('.cancer-question-input').val();
            saveCancerQuestions(questionId, optionAnswer, textAnswer, itemId)
        }

        function saveCancerQuestions(questionId, optionAnswer, freeTextAnswer, comboBoxItemId) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.questionId = parseInt(questionId);
            obj.optionAnswer = (optionAnswer == undefined) ? -1 : parseInt(optionAnswer);
            obj.freeTextAnswer = (freeTextAnswer == undefined) ? '' : freeTextAnswer;
            obj.comboBoxItemId = (comboBoxItemId == undefined) ? 0 : parseInt(comboBoxItemId);

            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveCancerFollowUpQuestions",
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

    </script>
</telerik:RadScriptBlock>
<div class="control-section-header abnorHeader">Pathway plan</div>
<div class="control-content">
    <table style="display: none;">
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
    <asp:Repeater ID="FollowUpQuestionsRepeater" runat="server" OnItemDataBound="FollowUpQuestionsRepeater_ItemDataBound">
        <HeaderTemplate>
            <table class="DataBoundTable" cellpadding="3" cellspacing="3" style="width: 100%">
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td style="vertical-align: top; width: 25%;">
                    <asp:HiddenField ID="QuestionIdHiddenField" runat="server" Value='<%#Eval("QuestionId") %>'/>
                    <asp:Image ID="QuestionMandatoryImage" runat="server" ImageUrl="../Images/NEDJAG/Mand.png" AlternateText="Mandatory Field" />
                    <telerik:RadLabel runat="server" ID="lblQuestion" Text='<%#Eval("Question") %>' />
                </td>
                <td style="vertical-align: top; width: 75%;">
                    <asp:RadioButtonList ID="QuestionOptionRadioButton" runat="server" AutoPostBack="false" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="cancer-question-option" data-itemid='<%#Eval("QuestionId") %>' Style="margin-right: 10px;">
                        <asp:ListItem Text="Yes" Value="1" style="margin-right: 10px;" />
                        <asp:ListItem Text="No" Value="0" style="margin-right: 10px;" />
                    </asp:RadioButtonList>
                   <telerik:RadTextBox ID="QuestionAnswerTextBox" runat="server" Skin="Metro" CssClass="cancer-question-input" data-itemid='<%#Eval("QuestionId") %>' />
                    <telerik:RadComboBox ID="QuestionOptionComboBox" Visible="false" runat="server" DataTextField="ListItemText" DataValueField="ListId" CssClass="cancer-question-combobox" Skin="Metro" Width="250" OnClientSelectedIndexChanged="getComboboxSelectedItem"/>
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>
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