class AppConfig {
  static String apiUrl = '';
  static String url = '';
  static String imageUrl = '';
  static String branchId = '';
  static String clientId = '';


  static void setEnvironment(String env) {
    switch (env) {
      case 'dev':
         // apiUrl = 'http://localhost:3004/api/';



         //    apiUrl = 'http://10.0.2.2:3004/api/';
         /*//   apiUrl = 'http://13.218.189.89/api/';*/
           apiUrl = 'https://mobile.beige.app/api/';
           imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/'; // Dev URL


        break;
       case 'prod':
        // apiUrl = 'https://api-apm.nextgengurukul.com/api/';
        apiUrl = 'http://98.82.122.237/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/'; // Dev URL

        break;
      default:
        apiUrl = '';
        break;
    }
  }
}
