package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"os"
	"strings"

	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	awsConfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

const (
	imageMapFileName = "image_map.txt"
)

var (
	config    Config
	s3Client  s3.Client
	imageKeys []string
)

type ResponseWithLink struct {
	Id   string `json:"id"`
	Link string `json:"link"`
}

type Config struct {
	domainName string
	bucketName string
}

func newS3Client() error {
	c, err := awsConfig.LoadDefaultConfig(context.TODO())

	if err != nil {
		return err
	}

	s3Client = *s3.NewFromConfig(c)

	return nil
}

func randomImage() (string, error) {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	if len(imageKeys) > 0 {
		fmt.Println("returning image key from cache")
		rn := rng.Intn(len(imageKeys))
		return imageKeys[rn], nil
	}

	i := "error"

	r, err := s3Client.GetObject(
		context.TODO(),
		&s3.GetObjectInput{
			Bucket: &config.bucketName,
			Key:    aws.String(imageMapFileName),
		},
	)

	if err != nil {
		fmt.Println("error retrieving image map file")
		return i, err
	}

	defer r.Body.Close()

	contentBytes, err := io.ReadAll(r.Body)

	if err != nil {
		return i, err
	}

	imageKeys = append(imageKeys, strings.Split(string(contentBytes), "|")...)

	if len(imageKeys) == 0 {
		fmt.Println("there are no image keys present, returning 'error'")
		return i, nil
	}

	return imageKeys[rng.Intn(len(imageKeys))], nil
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Println("handling request ", request.Path)

	image, err := randomImage()

	if err != nil {
		fmt.Println("error retrieving random link - ", err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "internal error"}, err
	}

	responseBody := ResponseWithLink{
		// https://DOMAIN/img/IMG NAME
		Link: fmt.Sprintf("https://%s/img/%s", config.domainName, image),
		Id:   image,
	}

	responseBodyJsonBytes, err := json.Marshal(responseBody)

	if err != nil {
		fmt.Println("error marshalling JSON - ", err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "internal error"}, err
	}

	response := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(responseBodyJsonBytes),
		Headers: map[string]string{
			"Access-Control-Allow-Methods": "OPTIONS,GET",
			"Access-Control-Allow-Headers": "Content-Type",
			"Access-Control-Allow-Origin":  "*",
		},
	}

	return response, nil
}

func main() {
	newS3Client()

	config.bucketName = os.Getenv("BUCKET_NAME")
	config.domainName = os.Getenv("DOMAIN_NAME")

	lambda.Start(handleRequest)
}
