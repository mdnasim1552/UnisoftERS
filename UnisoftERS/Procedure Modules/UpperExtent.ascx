<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="UpperExtent.ascx.vb" Inherits="UnisoftERS.UpperExtent"   %>
<style type="text/css">
    .extent-results td {
        min-height: 21px;
    }

    .failed-intubation-options tr td {
        width: auto !important;
    }

    .failed-intubation-options td:last-child {
        vertical-align: bottom;
    }

    .uncessful-extext-options {
        width: 50% !important;
    }

        .uncessful-extext-options td {
            width: 33%;
            width: 33%;
        }

    .other-reason-entry {
        display: none;
    }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            toggleUpperExtent();
            toggleUpperLimitation(); 
            //Added by rony tfs-2830
            toggUpperExtentChangedControls();
            toggleLevelOfComplexity();
        });

        $(document).ready(function () {
            

            $('.other-reason-entry').on('focusout', function () {

                var endoscopistId = $(this).attr("data-endoscopistid");
                saveUpperExtentData(endoscopistId);
            });

            $('.other-limitation-entry').on('focusout', function () {

                var endoscopistId = $(this).attr("data-endoscopistid");
                saveUpperExtentData(endoscopistId);
            });
            //toggleUpperExtent();

            $('.complexity-level-rb input[type=radio]').on('change', function () {
                var selectedValue = $('input[name="' + $(this).attr("name") + '"]:checked').val();
                saveProcedureComplexity(selectedValue);
            });
        });

        function upper_extent_changed(sender, args) {            
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");  
            var LevelOfComplexity = $('#<%=ComplexityRadioButtonList.ClientID%> input:checked').val();
            var completionItem = ['Intubation failed', 'Abandoned'];
            var levelOfComplexityItemNA = getLevelOfComplexity();
            //Added by rony tfs-2830
            $('.cb-extent').each(function (idx, itm) {
                var plannedExtentVal = $("#PlannedExtentComboBoxInput").val();
                var ctrl1 = $find($(itm)[0].id);
                var selectedItem1 = ctrl1.get_selectedItem();
                var listOrderById = selectedItem1.get_attributes().getAttribute("data-upper-extent")
                if (parseInt(listOrderById) >= parseInt(plannedExtentVal) || listOrderById === undefined) {
                    $(itm).closest('.extent-results').find('.LimitationTR').hide();
                } else {
                    $(itm).closest('.extent-results').find('.LimitationTR').show();
                }

                if (parseInt(LevelOfComplexity) === levelOfComplexityItemNA && !completionItem.includes(selectedItem1._text)) {
                    $('#<%= ComplexityRadioButtonList.ClientID %> input[type="radio"]').prop('checked', false);
                    saveProcedureComplexity(0);
                    toggleNALevelOfComplexity(levelOfComplexityItemNA, true);
                } else if (completionItem.includes(selectedItem1._text)) {
                    toggleNALevelOfComplexity(levelOfComplexityItemNA, false);
                } else if (parseInt(LevelOfComplexity) !== levelOfComplexityItemNA && !completionItem.includes(selectedItem1._text)) {
                    toggleNALevelOfComplexity(levelOfComplexityItemNA, true);
                }
            });
            toggleUpperExtent();
            saveUpperExtentData(endoscopistId);            
        }
        //Added by rony tfs-2830
        function toggUpperExtentChangedControls() {
            $('.cb-extent').each(function (idx, itm) {
                var plannedExtentVal = $("#PlannedExtentComboBoxInput").val();
                var endoscopistId = $(this).attr("data-endoscopistid");
                var ctrl = $find($(itm)[0].id);
                var selectedItem = ctrl.get_selectedItem();
                var listOrderById = selectedItem.get_attributes().getAttribute("data-upper-extent")
                if (parseInt(listOrderById) >= parseInt(plannedExtentVal) || listOrderById === undefined) {
                    $(itm).closest('.extent-results').find('.LimitationTR').hide();
                } else {
                    $(itm).closest('.extent-results').find('.LimitationTR').show();
                }
            });
        }
        //Added by rony tfs-2830
        function resetUpperExtent() {            
            $('.cb-extent').each(function (idx, itm) { 
            $(".resetUpperExtent input").val("");
            var endoscopistId = $(this).attr("data-endoscopistid");
            $(itm).closest('.extent-results').find('.LimitationTR').hide();            

            var additionalInfo = $('.other-reason-entry[data-endoscopistid="' + endoscopistId + '"]');
            var limitationOther = $('.other-limitation-entry[data-endoscopistid="' + endoscopistId + '"]');
            var jmanoeuvreId = $('.cb-jmanoeuvre[data-endoscopistid="' + endoscopistId + '"]');
            var mucosalJunctionDistance = $find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>');
        <%--    var withdrawalMins = $find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>');--%>
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.extentId = 0; 
            obj.additionalInfo = ($(additionalInfo).length == 0) ? '' : $(additionalInfo).val(); 
            obj.limitationOther = ($(limitationOther).length == 0) ? '' : $(limitationOther).val();
            obj.limitedById = 0;
            obj.endoscopistId = endoscopistId;
            obj.jmanoeuvreId = (jmanoeuvreId.length == 0 ? -1 : parseInt($find($(jmanoeuvreId)[0].id).get_value()));
          <%--  obj.withdrawalMins = ($find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>') == null || $find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>').get_value() == '' ? 0 : withdrawalMins.get_value());--%>
            obj.mucosalJunctionDistance = ($find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>') == null || $find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>').get_value() == '' ? 0 : mucosalJunctionDistance.get_value());
                $.ajax({
                    type: "POST",
                    url: "../Procedure.aspx/saveUpperExtent",
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
            });
        }
        function limitation_changed(sender, args) {
            toggleUpperLimitation();
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            saveUpperExtentData(endoscopistId);            
        }

        function toggleUpperExtent() {
            
            $('.cb-extent').each(function (idx, itm) {
                var endoscopistId = $(this).attr('data-endoscopistid');

                var ctrl = $find($(itm)[0].id);
                var selectedText = ctrl.get_selectedItem().get_text().toLowerCase();

                var additionalInfo = $('.other-reason-entry[data-endoscopistid="' + endoscopistId + '"]');
                var additionalInfoLabel = $(additionalInfo).closest('tr').find('.other-reason-label');

                if (selectedText == 'abandoned' || selectedText == 'intubation failed') {
                    $(additionalInfo).show();
                    $(additionalInfoLabel).show();
                    $(additionalInfoLabel).text('Failed reason');                      
                }
                else {                   
                    $(additionalInfo).hide();
                    $(additionalInfoLabel).hide();
                }
            });
        }

        function toggleUpperLimitation() {
           
            $('.cb-limitation').each(function (idx, itm) {
                //var endoscopistId = $(this).attr('data-endoscopistid');

                var ctrl = $find($(itm)[0].id);
                
                var selectedText = ctrl.get_selectedItem().get_text().toLowerCase();

                var otherLimitationTR = $(itm).closest('.extent-results').find('.OtherLimitation');
                
                if (selectedText == 'other') {
                    $(otherLimitationTR).show();
                }
                else {
                    $(otherLimitationTR).hide();
                }
            });
        }
    

        function saveUpperExtent(sender, args) {
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            saveUpperExtentData(endoscopistId);
        }

        function saveUpperExtentData(endoscopistId) {

            var extentId = $('.cb-extent[data-endoscopistid="' + endoscopistId + '"]');
            var additionalInfo = $('.other-reason-entry[data-endoscopistid="' + endoscopistId + '"]');
            var limitationOther = $('.other-limitation-entry[data-endoscopistid="' + endoscopistId + '"]');
            var limitedById = $('.cb-limitation[data-endoscopistid="' + endoscopistId + '"]');
           
            var jmanoeuvreId = $('.cb-jmanoeuvre[data-endoscopistid="' + endoscopistId + '"]');

            var mucosalJunctionDistance = $find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>');
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
           
            obj.extentId = parseInt($find($(extentId)[0].id).get_value()); //parseInt(extentId);
            
            obj.additionalInfo = ($(additionalInfo).length == 0) ? '' : $(additionalInfo).val(); //otherText;
            obj.limitationOther = ($(limitationOther).length == 0) ? '' : $(limitationOther).val(); //otherText;
             obj.limitedById = parseInt($find($(limitedById)[0].id).get_value());
           /*added by mostafizur*/
            /*obj.limitedById = (limitedById.length == 0 ? -1 : parseInt($find($(limitedById)[0].id).get_value())); */
            
            obj.endoscopistId = endoscopistId;
            obj.jmanoeuvreId = (jmanoeuvreId.length == 0 ? -1 : parseInt($find($(jmanoeuvreId)[0].id).get_value()));
            obj.mucosalJunctionDistance = ($find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>') == null || $find('<%=MucosalJunctionDistanceRadNumericTextBox.ClientID%>').get_value() == '' ? 0 : mucosalJunctionDistance.get_value());

           

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveUpperExtent",
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

        function mucosalJunctionDistance_changed(sender, args) {
            $('.cb-extent').each(function (idx, itm) {
                var endoscopistId = $(this).attr('data-endoscopistid');

                saveUpperExtentData(endoscopistId);
            });
        }

        function saveProcedureComplexity(id) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureComplexityId = parseInt(id);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveLevelOfComplexity",
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

        function toggleLevelOfComplexity() {
            var completionItem = ['Intubation failed', 'Abandoned'];
            var completionSelectedItem = '';
            $('.cb-extent').each(function (idx, itm) {
                var ctrl = $find($(itm)[0].id);
                var selectedItem = ctrl.get_selectedItem();
                completionSelectedItem = selectedItem._text;
            });

            //var text = '1 - Deep cannulation of duct of interest via main papilla, biopsy/cytology Biliary stent removal/exchange';
            //var radio = $("[id*=ComplexityRadioButtonList] label:contains('" + text + "')").closest("td").find("input").val();
            var selectedLevelOfComplexity = getLevelOfComplexity();

            if (!completionItem.includes(completionSelectedItem)) {
                $('#ComplexityRadioButtonList input[value="' + selectedLevelOfComplexity + '"]').prop('disabled', true);
                $('#ComplexityRadioButtonList input[value="' + selectedLevelOfComplexity + '"]').css('opacity', 0.5);
                $('#ComplexityRadioButtonList input[value="' + selectedLevelOfComplexity + '"]').closest('td').find('label').css('opacity', 0.5);
            }
        }

        function getLevelOfComplexity() {
            var selectedLevelOfComplexity = 0;
            $('.complexity-level-rb input[type=radio]').each(function (idx, itm) {
                if ($(itm).closest('td').find('label').text().toLowerCase() === 'n\\a') {
                    selectedLevelOfComplexity = parseInt($(itm).closest('td').find('input').val());
                }
            });
            return selectedLevelOfComplexity;
        }

        function toggleNALevelOfComplexity(levelOfComplexityItemNA, enable) {
            $('#ComplexityRadioButtonList input[value="' + levelOfComplexityItemNA + '"]').prop('disabled', enable);
            $('#ComplexityRadioButtonList input[value="' + levelOfComplexityItemNA + '"]').css('opacity', enable ? 0.5 : 1);
            $('#ComplexityRadioButtonList input[value="' + levelOfComplexityItemNA + '"]').closest('td').find('label').css('opacity', enable ? 0.5 : 1);
        }

    </script>
</telerik:RadScriptBlock>

<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Metro" DecorationZoneID="controlcontent" />
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<%--<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
<ContentTemplate>--%>
  
    <div id="controlcontent" class="control-content">

<table id="MucosalJunctionDistanceTR" runat="server">
          <tr>
          <td>
              <b><asp:Label runat="server" ID="Label1" Text="The apparent mucosal junction at" /></b>
          </td>
          <td>
               <telerik:RadNumericTextBox ID="MucosalJunctionDistanceRadNumericTextBox" runat="server"
                     IncrementSettings-InterceptMouseWheel="false"
                     IncrementSettings-Step="1"
                     Width="45px"
                     MinValue="0"
                     MaxValue="50"
                     Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                     <ClientEvents OnValueChanged="mucosalJunctionDistance_changed" />
                     <NumberFormat DecimalDigits="0" />
                 </telerik:RadNumericTextBox>
                 <asp:Label runat="server" ID="Label2" Text="cm" />
          </td>
      </tr>
</table>

    <asp:Repeater ID="rptUpperExtent" runat="server">
        <HeaderTemplate>
            <table style="width: 100%;" class="endo-extent">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <td style="width: 50%;">
                <table class="extent-results">
                    <tr>
                        <td colspan="2">
                            <asp:HiddenField ID="EndoscopistIdHiddenValue" runat="server" Value='<%#Eval("EndoscopistId") %>' />
                            <asp:Label ID="lblEndoscopistName" runat="server" Text='<%#Eval("EndoscopistName") %>' Style="font-weight: bold; font-size: 14px;" />
                             <%--Added by rony tfs-3761--%>
                            <asp:Label ID="Label3" runat="server" Text='<%#Eval("TraineeTrainer") %>' Style="font-size: 13px;" /> 
                        </td>
                    </tr>
                    <tr id="JManoeuvreTR" runat="server">
                        <td>J manoeuvre</td>
                        <td>
                            <telerik:RadComboBox ID="JManoeuvreRadComboBox" runat="server" Skin="Metro" CssClass="cb-jmanoeuvre" OnClientSelectedIndexChanged="saveUpperExtent">
                                <Items>
                                    <telerik:RadComboBoxItem Text="" Value="-1" />
                                    <telerik:RadComboBoxItem Text="Yes" Value="1" />
                                    <telerik:RadComboBoxItem Text="No" Value="0" />
                                </Items>
                            </telerik:RadComboBox>
                        </td>
                    </tr>
                    <tr class="resetUpperExtent plannedLabel">
                        <td>Completion to</td>
                        <td>
                            <%--Added by rony tfs-2830--%>
                            <telerik:RadComboBox ID="UpperExtentComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="upper_extent_changed" CssClass="cb-extent"  OnItemDataBound="UpperExtentRadComboBox_ItemDataBound"/>
                        </td>
                    </tr>
                    <tr id="FailedExtentTR" runat="server" class="FailedExtentTR resetUpperExtent">
                        <td><span class="other-reason-label"></span></td>
                        <td>
                            <asp:TextBox ID="FailedOtherTextBox" runat="server" Skin="Metro" CssClass="other-reason-entry" />&nbsp;
                        </td>
                    </tr>
                    <tr id="LimitationTR" runat="server" class="FailedExtentTR LimitationTR resetUpperExtent">
                        <td>Extent limited by</td>
                        <td>
                            <telerik:RadComboBox ID="InsertionLimitedRadComboBox" runat="server" CssClass="cb-limitation" Skin="Metro" DataTextField="Description" DataValueField="UniqueId"   OnClientSelectedIndexChanged="limitation_changed"/>
                        </td>
                    </tr>
                    <tr runat="server" class="OtherLimitationTR resetUpperExtent">
                        <td><span class="other-reason-label OtherLimitation">other limitation</span>&nbsp;</td>
                        <td>
                            <asp:TextBox ID="OtherLimitationTextBox" runat="server" Skin="Metro" CssClass="other-limitation-entry OtherLimitation" />&nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </tr>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</div>

<%--</ContentTemplate>
   

</asp:UpdatePanel>--%>
<div id="levelOfComplexity" runat="server" visible="false">
    <div class="control-sub-header">Level of complexity</div>
    <div class="control-content">
         <asp:RadioButtonList id="ComplexityRadioButtonList" CssClass="complexity-level-rb" Width="100%" runat="server" ClientIDMode="Static">
         </asp:RadioButtonList>
    </div>
</div>