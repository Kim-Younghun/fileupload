<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>   
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>   
<%@ page import="vo.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%
	// upload 폴더 경로를 저장
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + "addBoardAcion dir");
	// 파일 용량을 설정
	int max = 10 * 1024 * 1024;
	// request객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 -> multipart/form-data 사용
	// new DefaultFileRenamePolicy() -> 이름이 동일하게 중첩되지 안도록 함.
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	// MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다.
	// 업로드 파일의 타입이 PDF파일이 아니면 
	if(mRequest.getContentType("boardFile").equals("application/pdf") == false) {
		// 이미 업로드된 파일을 삭제
		System.out.println("PDF파일이 아닙니다.");
		String saveFilename = mRequest.getFilesystemName("boardFile");
		// 풀 경로명 작성(new File(d:/abc/uploadimage.jpg)), 운영체제별 /, \ 사용이 다르다. -> / 사용해도 프로그램상 자동변경됨
		// 자바 문법에서 \\가 \의 의미를 갖는다.
		File f = new File(dir +"\\"+ saveFilename);
		// 파일이 존재할경우 삭제 , 없다면 null
		if(f.exists()) {
			f.delete();
			System.out.println(saveFilename+"PDF파일 삭제");
		}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp");
		return;
	}
	
	// 1) input type="text" 값반환 API -> board 테이블 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	System.out.println(boardTitle + "addBoardAcion boardTitle");
	System.out.println(memberId + "addBoardAcion memberId");
	
	// 저장해야 boardNo 생성
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	// 2) input type="file" 값(파일 메타 정보)반환 API(원본파일이름, 저장된파일이름, 컨텐츠타입)
	// --> board_file 테이블 저장
	// 파일(바이너리)은 이미 MultipartRequest객체생성시(request랩핑시, 11라인) 먼저 저장
	String type = mRequest.getContentType("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	
	System.out.println(type + "addBoardAcion type");
	System.out.println(originFilename + "addBoardAcion originFilename");
	System.out.println(saveFilename + "addBoardAcion saveFilename");
	
	BoardFile boardFile = new BoardFile();
	// boardFile.setBoardNo(boardNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	 
	/* 
		INSERT INTO board(board_title, member_id, createdate, updatedate)
		VALUES(?, ?, NOW(), NOW());
	
		INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
		VALUES(?, ?, ?, ?, ?, NOW());
		
		INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
		String sql = "INSERT 쿼리문";
		pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row = pstmt.executeUpdate(); // insert 쿼리 실행
		ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select쿼리를 진행
		int keyValue = 0;
		if(keyRs.next()){
			keyValue = rs.getInt(1);
		}
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	String boardSql = "INSERT INTO board(board_title, member_id, createdate, updatedate) VALUES(?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	System.out.println(boardStmt + "addBoardAcion param boardStmt");
	// board에 입력후 키값저장
	boardStmt.executeUpdate();
	// 가장 최근 board_no(Auto Increment)가 저장(반환)된다.
	ResultSet KeyRs = boardStmt.getGeneratedKeys();
	int boardNo = 0;
	// 한번 동작
	if(KeyRs.next()) {
		boardNo = KeyRs.getInt(1);
	}
	
	// path경로를 upload으로 저장
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	System.out.println(fileStmt + "addBoardAcion param fileStmt");
	// board_file 입력
	fileStmt.executeUpdate();
	
	// 등록후 보드리스트로 리다이렉션
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
%>
