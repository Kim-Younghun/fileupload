<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>add board + file</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<h1>자료 업로드</h1>
	<!-- 
		Stream type 이므로 url로 보내지 않음 -> post	방식 사용, 
		이미지 or file을 전송하기 위해 multipart/form-data 사용,
		프로젝트명이 변경될 경우를 대비하여 <%=request.getContextPath()%>사용
	-->
	<form method="post" enctype="multipart/form-data" action="<%=request.getContextPath()%>/addBoardAction.jsp">
		<table>
			<!-- 자료 업로드 제공 -->
			<tr>
				<th>boardTitle</th>
				<td>
					<!-- required="required" 사용하여 사용자가 값을 넣지 않았을 때 제출버튼을 누를수 없도록 함 -->
					<textarea cols="50" rows="3" name="boardTitle" required="required"></textarea>
				</td>
			</tr>
			
			<!-- 로그인 사용자 아이디 -->
			<%
				// String memberId = (String)session.getAttribute("loginMemberId"); tptusrp
				String memberId = "test";
			%>
			<tr>
				<th>memberId</th>
				<td>
					<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">
				</td>
			</tr>
			<!-- 파일 업로드 -->
			<tr>
				<th>boardFile</th>
				<td>
					<input type="file" name="boardFile" required="required">
				</td>
			</tr>
		</table>
		<button type="submit">자료업로드</button>
	</form>
</body>
</html>