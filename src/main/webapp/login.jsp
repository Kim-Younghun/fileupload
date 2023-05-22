<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<!-- 로그인 폼 -->
	<%
		if(session.getAttribute("loginMemberId") == null) { // 로그인전이면 로그인폼출력
	%>
			
			<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
				<table>
					<tr>
						<td>아이디</td>
						<td><input type="text" name="memberId"></td>
					</tr>
					<tr>
						<td>비밀번호</td>
						<td><input type="password" name="memberPw"></td>
					</tr>
				</table>
				<button type="submit">로그인</button>
			</form>
	<%
		}
	%>  	
</body>
</html>