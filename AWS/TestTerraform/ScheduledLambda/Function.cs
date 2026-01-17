using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ScheduledLambda;

public class Function
{
    
    /// <summary>
    /// A simple function that takes a string and does a ToUpper
    /// </summary>
    /// <param name="input">The event for the Lambda function handler to process.</param>
    /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
    /// <returns></returns>
    /// public void FunctionHandler(CloudWatchEvent<dynamic> evnt, ILambdaContext context)

    public string FunctionHandler(object input, ILambdaContext context)
    {
        // return the input json, handle possible null
        return input?.ToString() ?? string.Empty;
    }
}
