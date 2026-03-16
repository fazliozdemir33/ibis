<?php
session_start();

class FirebaseService
{
    private $authFile = 'firebase_credentials.json';
    private $projectId;
    private $privateKey;
    private $clientEmail;
    private $accessToken;
    private $tokenExpiry;

    public function __construct()
    {
        if (!file_exists($this->authFile)) {
            die('Error: ' . $this->authFile . ' not found.');
        }

        $authData = json_decode(file_get_contents($this->authFile), true);
        if (!$authData) {
            die('Error: Invalid JSON in credentials file.');
        }

        $this->projectId = $authData['project_id'];
        $this->privateKey = $authData['private_key'];
        $this->clientEmail = $authData['client_email'];

        // Get Access Token using Service Account
        $this->refreshAccessToken();
    }

    private function refreshAccessToken()
    {
        // Check session cache
        if (isset($_SESSION['fb_access_token']) && isset($_SESSION['fb_token_expiry'])) {
            if (time() < $_SESSION['fb_token_expiry'] - 60) {
                $this->accessToken = $_SESSION['fb_access_token'];
                return;
            }
        }

        // Generate JWT for Google OAuth2
        $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
        $now = time();
        $claimSet = json_encode([
            'iss' => $this->clientEmail,
            'scope' => 'https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/cloud-platform',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => $now + 3600,
            'iat' => $now
        ]);

        $base64Header = $this->base64UrlEncode($header);
        $base64ClaimSet = $this->base64UrlEncode($claimSet);
        $signatureInput = $base64Header . "." . $base64ClaimSet;

        $signature = '';
        if (!openssl_sign($signatureInput, $signature, $this->privateKey, 'SHA256')) {
            die('Error: Failed to sign JWT.');
        }
        $base64Signature = $this->base64UrlEncode($signature);
        $jwt = $signatureInput . "." . $base64Signature;

        // Request Access Token
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt
        ]));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);

        $tokenData = json_decode($response, true);
        if (isset($tokenData['access_token'])) {
            $this->accessToken = $tokenData['access_token'];
            $_SESSION['fb_access_token'] = $this->accessToken;
            $_SESSION['fb_token_expiry'] = time() + $tokenData['expires_in'];
        } else {
            die('Error getting access token: ' . $response);
        }
    }

    private function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    // --- FIRESTORE OPERATIONS ---

    public function getDocuments($collection)
    {
        $url = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/(default)/documents/{$collection}";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->accessToken
        ]);

        $response = curl_exec($ch);

        $data = json_decode($response, true);
        $results = [];

        if (isset($data['documents'])) {
            foreach ($data['documents'] as $doc) {
                // Extract ID
                $pathParts = explode('/', $doc['name']);
                $id = end($pathParts);

                // Extract Fields
                $fields = $this->parseFields($doc['fields']);
                $fields['id'] = $id;

                $results[] = $fields;
            }
        }
        return $results;
    }

    public function addDocument($collection, $data)
    {
        $url = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/(default)/documents/{$collection}";

        // Convert simple array to Firestore format
        $firestoreData = ['fields' => $this->formatFields($data)];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($firestoreData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->accessToken,
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);

        return json_decode($response, true);
    }

    public function deleteDocument($collection, $id)
    {
        $url = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/(default)/documents/{$collection}/{$id}";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->accessToken
        ]);

        curl_exec($ch);
    }

    public function getAdminSettings()
    {
        $url = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/(default)/documents/settings/admin";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->accessToken
        ]);

        $response = curl_exec($ch);

        $data = json_decode($response, true);
        if (isset($data['fields'])) {
            return $this->parseFields($data['fields']);
        }
        return null;
    }

    public function updateAdminSettings($data)
    {
        $url = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/(default)/documents/settings/admin";

        $firestoreData = ['fields' => $this->formatFields($data)];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PATCH");
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($firestoreData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->accessToken,
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);

        return json_decode($response, true);
    }

    // Helper: Convert Firestore format to simple array
    private function parseFields($fields)
    {
        $result = [];
        foreach ($fields as $key => $value) {
            if (isset($value['stringValue']))
                $result[$key] = $value['stringValue'];
            elseif (isset($value['integerValue']))
                $result[$key] = (int) $value['integerValue'];
            elseif (isset($value['booleanValue']))
                $result[$key] = $value['booleanValue'];
            elseif (isset($value['timestampValue']))
                $result[$key] = $value['timestampValue'];
            // Add other types as needed
        }
        return $result;
    }

    // Helper: Convert simple array to Firestore format
    private function formatFields($data)
    {
        $fields = [];
        foreach ($data as $key => $value) {
            if (is_string($value))
                $fields[$key] = ['stringValue' => $value];
            elseif (is_int($value))
                $fields[$key] = ['integerValue' => $value];
            elseif (is_bool($value))
                $fields[$key] = ['booleanValue' => $value];
        }
        return $fields;
    }
}

function checkAuth()
{
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        header('Location: login.php');
        exit;
    }
}
?>