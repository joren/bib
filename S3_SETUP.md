# AWS S3 Setup for Production

This application uses AWS S3 for file storage in production environments.

## Prerequisites

1. An AWS account
2. An S3 bucket created
3. An IAM user with S3 access

## Steps to Configure

### 1. Create an S3 Bucket

1. Log in to AWS Console
2. Navigate to S3
3. Click "Create bucket"
4. Choose a unique bucket name (e.g., `bib-production`)
5. Select a region (e.g., `us-east-1`)
6. Configure bucket settings:
   - **Block Public Access**: Keep all public access blocked (recommended)
   - **Versioning**: Optional, but recommended for backups
   - **Encryption**: Enable default encryption

### 2. Configure CORS (if needed for direct uploads)

Add the following CORS configuration to your bucket:

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": ["https://yourdomain.com"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```

### 3. Create IAM User

1. Navigate to IAM in AWS Console
2. Create a new user (e.g., `bib-storage`)
3. Attach the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bib-production",
        "arn:aws:s3:::bib-production/*"
      ]
    }
  ]
}
```

4. Create access keys for the user
5. Save the `Access Key ID` and `Secret Access Key`

### 4. Add Credentials to Rails

Edit your encrypted credentials file:

```bash
EDITOR="vim" bin/rails credentials:edit
```

Add the following structure:

```yaml
aws:
  access_key_id: YOUR_ACCESS_KEY_ID
  secret_access_key: YOUR_SECRET_ACCESS_KEY
  region: us-east-1
  bucket: bib-production
```

**Important:** Never commit your credentials to the repository! The `config/credentials.yml.enc` file is safe to commit, but `config/master.key` should never be committed.

### 5. Deploy

When deploying to production, ensure the `RAILS_MASTER_KEY` environment variable is set to the contents of your `config/master.key` file.

For Kamal deployment, add to `.kamal/secrets`:

```bash
RAILS_MASTER_KEY=$(cat config/master.key)
```

## Testing in Production

After deploying:

1. Upload a book through the web interface
2. Verify the file appears in your S3 bucket
3. Download the book to confirm the download link works
4. Check that cover images load correctly

## Local Development

Local development continues to use local disk storage (`:local` service). No AWS credentials are needed for development.

## Troubleshooting

### "Access Denied" errors

- Verify IAM user has correct permissions
- Check that the bucket name in credentials matches the actual bucket
- Ensure the bucket and IAM user are in the same AWS account

### Files not appearing in S3

- Check Rails logs for upload errors
- Verify `config.active_storage.service = :amazon` in `config/environments/production.rb`
- Ensure credentials are loaded correctly (check `Rails.application.credentials.dig(:aws, :bucket)` in console)

### Slow uploads/downloads

- Ensure your server and S3 bucket are in the same or nearby regions
- Consider using CloudFront CDN for faster delivery
- Check your internet connection and S3 region latency

## Cost Considerations

- S3 storage costs approximately $0.023 per GB per month (us-east-1)
- Data transfer out of S3 has costs (first 1 GB/month is free)
- Monitor your AWS billing dashboard regularly
- Set up billing alerts for unexpected charges

## Security Best Practices

1. Never commit AWS credentials to version control
2. Use IAM policies with minimum required permissions
3. Enable S3 bucket logging for audit trails
4. Regularly rotate access keys
5. Use MFA for AWS console access
6. Consider using AWS Secrets Manager for production credentials
