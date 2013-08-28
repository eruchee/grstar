
class IdTest{
	public static void main(String[] args){
		String s1 = "tag:google.com,2005:reader/item/5bb0f8a02c62a73e";
		String s2 = "tag:google.com,2005:reader/item/5bb0f8a02c62a73e";
		
		if (s1.equals(s2) == true){
			System.out.println("match");
		}
	}
}