    <script src="../../../Scripts/jquery-1.11.0.min.js"></script>
    <script type="text/javascript">
        function isIE() {
            var ua = window.navigator.userAgent;
            var msie = ua.indexOf("MSIE ");
            if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))  // If Internet Explorer, return version number
            {
                return true
            }
            else {
                return false;
            }

        }
        $(document).ready(function () {
            var ToolBarBGStyle = 'font-family: Verdana; font-size: 8pt; border-bottom-color: rgb(204, 204, 204); border-bottom-width: 1px; border-bottom-style: solid; background-color: -webkit-linear-gradient(#E3ECFD, #C3DCDD, #E3ECFD); background-color: -o-linear-gradient(#E3ECFD, #C3DCDD, #E3ECFD);background-color: -moz-linear-gradient(#E3ECFD, #C3DCDD, #E3ECFD); background-color: linear-gradient(#E3ECFD, #C3DCDD, #E3ECFD); background-image:url("../../../Images/RVBackground.png");';
            if (isIE() == true) {
                $("#PrintBtn").hide();
            }
            $("#PrintBtn").click(PrintDiv);
            $("#RV_ctl05").attr("style", ToolBarBGStyle);
        });
        function PrintDiv() {
            var divPrint = $("div[id$='ReportDiv']").parent();
            var RCS = $("head style[id$='ReportControl_styles']");
            newWin = window.open("");
            newWin.document.write('<html xmlns="http://www.w3.org/1999/xhtml"><head><style type="text/css">' + RCS.html() + '</style></head><body>' + divPrint.html() + '</body>');
            newWin.document.close();
            newWin.print();
            newWin.close();
        }
    </script>
    <link href="../../../Styles/Reporting.css" rel="stylesheet" />
