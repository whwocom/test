<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.matrix.framework.common.security.matrix.AuthManager" %>
<%
    String id = RequestWrapper.filter(request.getParameter("id"));
    String defaultLangCode = "en";
    String langCode = AuthManager.getInstance().getAttribute("LANG_CODE", defaultLangCode).toString();    
    String lowerLang = langCode.toLowerCase();
    switch (lowerLang) {
        case "jp":
            langCode = "ja";
            break;
        case "ch":
            langCode = "zh";
            break;
        case "mx":
            langCode = "es-MX";
            break;
        case "ko":
        case "en":
        case "vi":
        case "pt":
            langCode = lowerLang;
            break;
        default:
            langCode = defaultLangCode; // 지정한 언어코드에 없으면 기본값으로
            break;
    }

	com.matrix.script.ScriptUtility utility  = new com.matrix.script.ScriptUtility();
	com.matrix.collection.KeyValueCollection reqParams = new com.matrix.collection.KeyValueCollection();
	reqParams.Add("OUT", "1"); //JOSN output
	reqParams.Add("hashcode", utility.getUniqueKey("HASH_")); 
	reqParams.Add("ukey", utility.getUniqueKey("UKEY")); 
	reqParams.Add("#CLASS_NAME#", "");
	com.matrix.Data.Packet packet = new com.matrix.Data.Packet(request, response, reqParams);

	// 파라미터 전달
	String param_name;
	String param_value;
	java.util.Enumeration  _epa_paramNames =  request.getParameterNames();
	while(_epa_paramNames.hasMoreElements()) {
		param_name  = (String) _epa_paramNames.nextElement();
		param_value = request.getParameter(param_name);
		packet.setParam(param_name, param_value);
	}

	List<Object> _SCRIPT_PARAMS_ = new ArrayList<Object>();

    //보고서로 전달될 파라미터 생성
    com.matrix.collection.KeyValueItem kvParam;
    Map<String,Object> script_param;
    for(int i=0,i2=packet.Params.Count();i<i2;i++){
        kvParam = packet.Params.get(i);        
        script_param = new HashMap<String,Object>();
        script_param.put("KEY", kvParam.Key);
        script_param.put("VALUE", kvParam.Value);
        _SCRIPT_PARAMS_.add(script_param);
    }

%>
<!DOCTYPE html>
<html lang="<%=langCode%>" class="istudio">
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <%@include file="../portal/SessionChk_popup.jsp"%>
	<%@include file="../AUD/include/Framework.jspf"%>
	<link rel="stylesheet" type="text/css" href="<%=CONTEXT_PATH%>/eform/css/eform-tokens.css">
	<link rel="stylesheet" type="text/css" href="<%=CONTEXT_PATH%>/eform/css/eform-components.css">
    <link rel="stylesheet" type="text/css" href="<%=CONTEXT_PATH%>/eform/css/sheet.css">
    <link rel="stylesheet" type="text/css" href="<%=CONTEXT_PATH%>/eform/css/eform-report.css">
    <link rel="stylesheet" type="text/css" href="<%=CONTEXT_PATH%>/eform/font/icon.css">
	
    <script type="text/javascript" src="<%=CONTEXT_PATH%>/eform/js/eform.common.js"></script>
    <script type="text/javascript" src="<%=CONTEXT_PATH%>/eform/js/sheet.js"></script>
	
	<script type="text/javascript" src="<%=CONTEXT_PATH%>/extention/AUD/customscript.jsp"></script>
	<style>
        input {
            outline: none;
        }
        
        input:focus {
            border-color: #2563eb !Important;
            background-color: #ffffff !Important;
        }

        select {
            outline: none;
        }

        select:focus {
            border-color: #2563eb !Important;
            box-shadow: 0 0 0 1px rgba(37, 99, 235, 0.2);
        }	

        textarea {
            outline: none;
        }

        textarea:focus {
            border-color: #2563eb !Important;
            background-color: #ffffff !Important;
        }
 	</style>
</head>

<body class="istudio-common-viewer" >
    <div id="AudViewer" />
	<script type="text/javascript">
		$(document).ready(function($) {
            var reportCode = "<%=id%>";        // ReportCode
            var timeoutID = undefined;
            var viewerId = 'AudViewer'; 

            var AudOpenReport = function() {
                AUD.GetI18N().SetNamespaceToLanguageResource('eform:ui');
                AUD.GetI18N().SetNamespaceToLanguageResource('eform:message');
                AUD.SetFileDialogCallback(); //20211202 추가
				AUD.SetAUDOption("SQLExecuteType", "REPORT");
                AUD.LoadDocument(viewerId, reportCode, 2, false, null, 5);
            }

            /*
             *  Portal Viewer 의 동작 버튼 상에 연결을 위한 함수    
             *  portal - matrix.script.content.js 의 fnRefresh 함수에서 호출
             */

            // 실행
            var doRefresh = function() {
                AUD.DoRefresh();
            }
            // 다른 이름 저장
            var SaveAsReport = function() {
                AUD.SaveAsReport();
            }
            // Shell 닫기
		 	var fnShellClose = function(){
				AUD.ShellDialog.close();
			};
			// 내려 받기
			var fnExportEx = function(){
				AUD.ExcelExportManager.InitExport();
			}

			var fnScheAddClose = function(data){
				if (AUD.DialogBoxManager != null){
					AUD.DialogBoxManager.CloseAll();
				}
			}

            /* [조건 개인화 설정] 목록 가져오기 */
            var getReportFilters = function(isAuto) {
                var filterItems;
                if(typeof AUD.Utility.GetReportFilters === 'function') {
                    if(AUD.GetMainViewer().Document.PersonalConditions.useAll){
                        filterItems = AUD.Utility.GetReportFilters(isAuto);
                    }else {
                        filterItems = AUD.Utility.GetReportFilters(isAuto, null, function(control){
                        return AUD.GetMainViewer().Document.PersonalConditions.list.indexOf(control.Name) > -1
                        });
                    }

                }

                return filterItems;
            }
            
            /* [조건 개인화] 설정하기 */
            var setReportFilter = function(repCode, filterItems) {
                if(filterItems && Array.isArray(filterItems)) {

                    if(typeof AUD.Utility.SetReportFilters === 'function') {
                        AUD.Utility.SetReportFilters(filterItems);
                    }
                }  
            }

            var isFirstActiveForm = function(formId) {
                if(formId === AUD.GetMainViewer().FirstActiveFormId) {
                    return true;
                }else {
                    return false;
                }
            }

            var OnReportOpenCompleted = function(viewerID) {
                var viewer = undefined;
                if(viewerID) {
                    viewer = AUD.GetViewer(viewerID);
                }else {
                    viewer = AUD.GetMainViewer();
                }

                if(typeof AUD.GlobalConfig.USE_CONDITION !== "undefined" && AUD.GlobalConfig.USE_CONDITION) {
                    if(typeof parent.fnSetAUDReportViewer === "function") {
                        parent.fnSetAUDReportViewer(viewer);
                    }
                }
            }

            // viewer 재활용
            var LOAD_DOCUMENT = function(AudOpenReport) {
                try {
					<%-- [DEBUG] 파라미터 확인용 --%>
					<%-- console.log('[DEBUG] _SCRIPT_PARAMS_', <%=new com.google.gson.Gson().toJson(_SCRIPT_PARAMS_)%>); --%>
					AUD.SetCustomParams(<%=new Gson().toJson(_SCRIPT_PARAMS_)%>,false);

					AUD.ExtendLanguageNameSpace = ['eform'];
					try{
						AUD.Init(AudOpenReport);
					}catch(e){
						console.log("view.jsp AUD Initialize Error", e);
					}
					
					$(window).resize(function(e) {
						if($(e.target).hasClass('ui-resizable')) {
							return;
						}
						e.preventDefault();

						if(timeoutID) {
							clearTimeout(timeoutID);
						}

						timeoutID = setTimeout(function() {
							$(this).trigger('resizeEnd');
						}, 300);
					});

					$(window).on('resizeEnd', function(){
						AUD.GetMainViewer().ViewerSizeChanged();
					});
                } catch (e) {
                    console.log("i-AUD main.jsp LOAD_DOCUMENT Error::", e.message);
                }
            }

			LOAD_DOCUMENT(AudOpenReport);

		});
	</script>	
</body>
</html>